#!/bin/bash

################################################################################
# Node.js 离线安装脚本 - CentOS 7
# 功能：自定义路径安装、交互式输入、现有版本检测
# 使用: ./install_nodejs.sh
################################################################################

set -e

# ==================== 颜色定义 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== 配置变量 ====================
INSTALL_PATH=""
PKG_PATH=""
LOG_FILE="/tmp/nodejs_install_$(date +%s).log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"
INSTALL_RECORD="$HOME/.nodejs_install_record"

# ==================== 工具函数 ====================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 确认对话框
confirm_action() {
    local prompt="$1"
    read -p "  $(echo -e ${YELLOW})${prompt}$(echo -e ${NC}) (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# 显示使用说明
show_usage() {
    cat << EOF
${BLUE}=== Node.js 离线安装脚本 ===${NC}

用法:
  ./install_nodejs.sh

描述:
  纯交互式安装脚本，将指引您完成 Node.js 离线安装过程。

功能:
  • 检测本地已有的 Node.js 安装
  • 交互式输入自定义安装路径
  • 自动识别 packages/ 目录中的安装包
  • 无需 root 权限，完全用户级别安装

示例:
  ./install_nodejs.sh

EOF
}

# ==================== 现有版本检测 ====================
check_existing_nodejs() {
    if command -v node &> /dev/null; then
        node_version=$(node --version)
        npm_version=$(npm --version)
        node_path=$(which node)
        
        return 0
    else
        return 1
    fi
}

# ==================== 交互式输入函数 ====================
# 步骤 1: 询问是否已有安装
prompt_existing_install() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 检测现有 Node.js 安装    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if check_existing_nodejs; then
        log_success "检测到现有 Node.js 安装"
        echo -e "  ${YELLOW}版本:${NC} $node_version"
        echo -e "  ${YELLOW}npm 版本:${NC} $npm_version"
        echo -e "  ${YELLOW}路径:${NC} $node_path"
        echo ""
        
        if confirm_action "是否继续安装新版本?"; then
            return 0
        else
            log_warn "安装已取消"
            return 1
        fi
    else
        log_info "未检测到现有 Node.js 安装"
        echo ""
        if ! confirm_action "继续安装新版本?"; then
            log_warn "安装已取消"
            return 1
        fi
        return 0
    fi
}

# 步骤 2: 交互式输入安装路径
prompt_install_path() {
    local default_path="$HOME/nodejs"
    local user_input=""
    
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 2: 选择安装路径              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}默认路径:${NC} $default_path"
    read -p "  输入安装路径（直接回车使用默认）: " user_input
    
    if [ -z "$user_input" ]; then
        INSTALL_PATH="$default_path"
        log_info "使用默认安装路径: $INSTALL_PATH"
    else
        INSTALL_PATH="$user_input"
        log_info "使用自定义安装路径: $INSTALL_PATH"
    fi
    
    # 展开波浪号
    INSTALL_PATH="${INSTALL_PATH/#\~/$HOME}"
}

# 步骤 3: 交互式选择压缩包
prompt_package_path() {
    local default_pkg=""
    local user_input=""
    
    # 寻找 packages 目录下的 Node.js 包
    if [ -d "$DEFAULT_PKG_DIR" ]; then
        default_pkg=$(find "$DEFAULT_PKG_DIR" -maxdepth 1 -type f \( -name "node-*.tar.gz" -o -name "node-*.tar.xz" -o -name "node-*.zip" \) 2>/dev/null | head -1)
    fi
    
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 3: 选择压缩包                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if [ -n "$default_pkg" ]; then
        echo -e "  ${YELLOW}找到默认压缩包:${NC}"
        echo "    $(basename $default_pkg)"
        read -p "  使用此文件? (Y/n): " -n 1 -r user_input
        echo
        
        if [[ -z "$user_input" || $user_input =~ ^[Yy]$ ]]; then
            PKG_PATH="$default_pkg"
            log_info "使用默认压缩包: $(basename $default_pkg)"
            return 0
        fi
    fi
    
    echo -e "  ${YELLOW}默认目录:${NC} $DEFAULT_PKG_DIR"
    read -p "  输入压缩包路径: " user_input
    
    if [ -z "$user_input" ]; then
        log_error "必须指定压缩包路径"
        return 1
    else
        PKG_PATH="$user_input"
        log_info "使用压缩包: $PKG_PATH"
    fi
    
    # 展开波浪号
    PKG_PATH="${PKG_PATH/#\~/$HOME}"
}

# 步骤 4: 确认安装信息
confirm_installation_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 4: 确认安装信息              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}源包:${NC} $PKG_PATH"
    echo -e "  ${YELLOW}目标路径:${NC} $INSTALL_PATH"
    echo ""
    
    if ! confirm_action "确认开始安装?"; then
        log_warn "安装已取消"
        return 1
    fi
    
    return 0
}

# ==================== 卸载功能 ====================
uninstall_nodejs() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Node.js 卸载 - 交互式模式        ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -f "$INSTALL_RECORD" ]; then
        log_error "未找到安装记录文件: $INSTALL_RECORD"
        log_error "无法验证是否通过本脚本安装"
        return 1
    fi
    
    INSTALL_PATH=$(cat "$INSTALL_RECORD")
    
    if [ ! -d "$INSTALL_PATH" ]; then
        log_error "安装路径不存在: $INSTALL_PATH"
        return 1
    fi
    
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检测到安装信息                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}安装路径:${NC} $INSTALL_PATH"
    
    if ! confirm_action "确认卸载此安装?"; then
        log_warn "卸载已取消"
        return 1
    fi
    
    log_info "开始卸载..."
    
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  删除 Node.js 文件                 │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if [ -d "$INSTALL_PATH" ]; then
        log_info "删除目录: $INSTALL_PATH"
        rm -rf "$INSTALL_PATH"
        log_success "目录已删除"
    fi
    
    # 删除环境变量配置
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  删除环境变量配置                  │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    local bash_config="$HOME/.bashrc"
    local start_marker="# >>> Node.js Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local end_marker="# <<< Node.js Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    
    if grep -q "$start_marker" "$bash_config" 2>/dev/null; then
        log_info "检测到环境变量配置，正在删除..."
        
        # 使用 sed 删除标记之间的所有内容（包括标记本身和前后的空行）
        sed -i "/^$start_marker$/,/^$end_marker$/d" "$bash_config"
        # 删除可能的多余空行
        sed -i '/^$/N;/^\n$/D' "$bash_config"
        
        log_success "环境变量配置已删除"
        echo ""
        echo -e "${YELLOW}请执行以下命令使配置生效:${NC}"
        echo "  source ~/.bashrc"
    else
        log_info "未找到自动配置的环境变量"
        echo ""
        echo -e "${YELLOW}提示:${NC} 如果您手动配置了环境变量，请手动删除:"
        echo "  编辑 ~/.bashrc，移除包含 '$INSTALL_PATH' 的 PATH 配置行"
    fi
    
    echo ""
    log_info "删除安装记录..."
    rm -f "$INSTALL_RECORD"
    
    echo ""
    log_success "Node.js 卸载完成!"
}

# ==================== 更新配置功能 ====================
update_config() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Node.js 更新配置 - 交互式模式    ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -f "$INSTALL_RECORD" ]; then
        log_error "未找到安装记录文件: $INSTALL_RECORD"
        log_error "请先使用安装模式安装 Node.js"
        return 1
    fi
    
    INSTALL_PATH=$(cat "$INSTALL_RECORD")
    
    if [ ! -d "$INSTALL_PATH" ]; then
        log_error "安装路径不存在: $INSTALL_PATH"
        log_error "请重新安装 Node.js"
        return 1
    fi
    
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检测到安装信息                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}安装路径:${NC} $INSTALL_PATH"
    
    local node_version=$("$INSTALL_PATH/bin/node" --version)
    local npm_version=$("$INSTALL_PATH/bin/npm" --version)
    
    echo -e "  ${YELLOW}Node.js 版本:${NC} $node_version"
    echo -e "  ${YELLOW}npm 版本:${NC} $npm_version"
    echo ""
    
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  配置选项                         │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo "  1. 配置环境变量"
    echo "  2. 配置 npm 镜像源"
    echo "  3. 显示完整配置信息"
    echo "  0. 返回"
    echo ""
    
    read -p "  请选择操作 (0-3): " choice
    
    case "$choice" in
        1)
            echo ""
            echo -e "${YELLOW}配置环境变量:${NC}"
            echo ""
            
            local bash_config="$HOME/.bashrc"
            local start_marker="# >>> Node.js Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
            
            # 检查是否已配置
            if grep -q "$start_marker" "$bash_config" 2>/dev/null; then
                log_warn "环境变量已经配置过了"
                echo ""
            elif confirm_action "是否自动配置环境变量到 ~/.bashrc?"; then
                configure_env_variables
                echo -e "${YELLOW}请运行以下命令使配置生效:${NC}"
                echo "  source ~/.bashrc"
            fi
            ;;
        2)
            echo ""
            echo -e "${YELLOW}配置 npm 镜像源:${NC}"
            echo ""
            
            if confirm_action "将 npm 镜像源设置为淘宝源?"; then
                "$INSTALL_PATH/bin/npm" config set registry https://registry.npmmirror.com
                log_success "npm 镜像源已配置"
                "$INSTALL_PATH/bin/npm" config get registry
            fi
            ;;
        3)
            show_install_info
            ;;
        0)
            log_info "返回主菜单"
            ;;
        *)
            log_error "无效选择"
            return 1
            ;;
    esac
}

# ==================== 安装功能 ====================
install_nodejs() {
    # 验证参数
    if [ -z "$INSTALL_PATH" ]; then
        log_error "必须指定安装路径"
        return 1
    fi

    if [ -z "$PKG_PATH" ]; then
        log_error "必须指定压缩包路径"
        return 1
    fi

    if [ ! -f "$PKG_PATH" ]; then
        log_error "压缩包不存在: $PKG_PATH"
        return 1
    fi

    # 确认安装信息
    if ! confirm_installation_info; then
        return 1
    fi

    log_info "开始安装 Node.js..."

    # ========== 步骤 5: 检查目标路径 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 5: 检查目标路径              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if [ -d "$INSTALL_PATH" ]; then
        log_warn "安装路径已存在: $INSTALL_PATH"
        
        if ! confirm_action "是否覆盖现有目录?"; then
            log_warn "安装已取消"
            return 1
        fi
        
        log_info "删除现有目录..."
        rm -rf "$INSTALL_PATH"
    fi

    # ========== 步骤 6: 创建安装目录 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 6: 创建安装目录              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    mkdir -p "$INSTALL_PATH"
    log_success "已创建目录: $INSTALL_PATH"

    # ========== 步骤 7: 解压文件 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 7: 解压压缩包                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    log_info "解压文件..."
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    case "$PKG_PATH" in
        *.tar.gz)
            tar -xzf "$PKG_PATH" -C "$temp_dir"
            log_success "解压完成（tar.gz）"
            ;;
        *.tar.xz)
            tar -xJf "$PKG_PATH" -C "$temp_dir"
            log_success "解压完成（tar.xz）"
            ;;
        *.zip)
            unzip -q "$PKG_PATH" -d "$temp_dir"
            log_success "解压完成（zip）"
            ;;
        *)
            log_error "不支持的压缩格式: $PKG_PATH"
            return 1
            ;;
    esac

    # ========== 步骤 8: 移动文件 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 8: 复制文件到目标路径        │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    # 查找解压后的目录
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d ! -path "$temp_dir" | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "无法找到解压后的目录"
        return 1
    fi

    log_info "复制文件: $(basename "$extracted_dir") -> $INSTALL_PATH"
    
    # 复制所有内容到安装目录（确保 bin 目录直接在安装目录下）
    cp -r "$extracted_dir"/* "$INSTALL_PATH/"
    log_success "文件复制完成"
    
    # 验证关键目录结构
    if [ ! -d "$INSTALL_PATH/bin" ]; then
        log_error "错误: bin 目录不在安装路径下"
        log_error "请检查压缩包结构是否正确"
        return 1
    fi
    
    if [ ! -f "$INSTALL_PATH/bin/node" ]; then
        log_error "错误: 未找到 node 可执行文件"
        return 1
    fi
    
    log_success "目录结构验证通过: bin/ 在 $INSTALL_PATH 下"

    # ========== 步骤 9: 设置权限 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 9: 设置文件权限              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    log_info "设置文件权限..."
    chmod -R 755 "$INSTALL_PATH/bin"
    chmod -R 755 "$INSTALL_PATH/lib" 2>/dev/null || true
    log_success "权限设置完成"

    log_success "Node.js 安装成功!"
    
    # 保存安装记录
    echo "$INSTALL_PATH" > "$INSTALL_RECORD"
    log_info "安装记录已保存到: $INSTALL_RECORD"
    
    # 显示安装信息
    show_install_info
}

# 配置环境变量到 bashrc
configure_env_variables() {
    local bash_config="$HOME/.bashrc"
    local start_marker="# >>> Node.js Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local end_marker="# <<< Node.js Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local env_line="export PATH=\"$INSTALL_PATH/bin:\$PATH\""
    
    # 检查是否已存在配置
    if grep -q "$start_marker" "$bash_config" 2>/dev/null; then
        log_warn "环境变量已配置，跳过"
        return 0
    fi
    
    log_info "添加环境变量到 $bash_config"
    
    # 添加带注释标记的环境变量
    {
        echo ""
        echo "$start_marker"
        echo "$env_line"
        echo "$end_marker"
    } >> "$bash_config"
    
    log_success "环境变量已配置"
    echo ""
    echo -e "${YELLOW}重要提示:${NC}"
    echo -e "  请勿在以下标记之间添加或修改内容："
    echo -e "  ${CYAN}$start_marker${NC}"
    echo -e "  ${CYAN}$end_marker${NC}"
    echo -e "  卸载时将自动删除这些标记之间的所有内容"
    echo ""
}

# 显示安装信息
show_install_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 10: 安装完成                 │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    log_success "安装路径: $INSTALL_PATH"
    
    local node_version=$("$INSTALL_PATH/bin/node" --version)
    local npm_version=$("$INSTALL_PATH/bin/npm" --version)
    
    log_success "Node.js 版本: $node_version"
    log_success "npm 版本: $npm_version"

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  后续配置步骤                      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if confirm_action "是否自动配置环境变量到 ~/.bashrc?"; then
        configure_env_variables
        echo -e "${YELLOW}请执行以下命令使配置生效:${NC}"
        echo "   source ~/.bashrc"
        echo ""
    else
        echo -e "${YELLOW}手动配置环境变量:${NC}"
        echo "   echo 'export PATH=\"$INSTALL_PATH/bin:\$PATH\"' >> ~/.bashrc"
        echo "   source ~/.bashrc"
        echo ""
    fi
    
    echo -e "${YELLOW}验证安装:${NC}"
    echo "   source ~/.bashrc"
    echo "   node --version"
    echo "   npm --version"
    echo ""
    
    echo -e "${YELLOW}配置 npm 镜像源（可选）:${NC}"
    echo "   npm config set registry https://registry.npmmirror.com"
    echo ""
}

# ==================== 主函数 ====================
main() {
    # 初始化日志
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/nodejs_install.log"

    # 显示帮助信息（如果有参数）
    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    # 显示模式选择菜单
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Node.js 管理工具                 ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}选择操作模式:${NC}"
    echo ""
    echo "  1. 安装 Node.js"
    echo "  2. 卸载 Node.js"
    echo "  3. 更新配置"
    echo "  0. 退出"
    echo ""
    
    read -p "  请选择 (0-3): " mode_choice
    echo ""
    
    case "$mode_choice" in
        1)
            # 开始交互式安装流程
            echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║  Node.js 离线安装 - 交互式模式    ║${NC}"
            echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
            
            # 步骤 1: 检测现有安装
            if ! prompt_existing_install; then
                exit 1
            fi
            
            # 步骤 2: 输入安装路径
            prompt_install_path
            
            # 步骤 3: 选择压缩包
            if ! prompt_package_path; then
                exit 1
            fi
            
            # 步骤 4-10: 执行安装
            install_nodejs
            ;;
        2)
            # 卸载模式
            uninstall_nodejs
            ;;
        3)
            # 更新配置模式
            update_config
            ;;
        0)
            log_info "退出"
            exit 0
            ;;
        *)
            log_error "无效选择"
            exit 1
            ;;
    esac
}

main "$@"
