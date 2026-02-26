#!/bin/bash

################################################################################
# Claude Code Router 离线安装脚本 - CentOS 7 / Linux
# 功能：使用 npm 全局安装 Claude Code Router
# 特点：Node.js npm 包管理、交互式输入、无需 root 权限（用户级别全局安装）
# 使用: ./install_claude_code_router.sh
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
PKG_PATH=""
LOG_FILE="/tmp/claude_code_router_install_$(date +%s).log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"

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
    read -p "  $(echo -e "${YELLOW}")${prompt}$(echo -e "${NC}") (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# 显示使用说明
show_usage() {
    cat << EOF
${BLUE}=== Claude Code Router 离线安装脚本 ===${NC}

用法:
  ./install_claude_code_router.sh

描述:
  纯交互式安装脚本，使用 npm 全局安装 Claude Code Router。

要求:
  • Node.js 16.0.0 或更高版本
  • npm 8.0.0 或更高版本
  • 互联网连接（首次运行 pack 脚本时获取包）或离线包

功能:
  • 检测 Node.js 和 npm 环境
  • 检测已有的 Claude Code Router 安装
  • 自动识别 packages/ 目录中的离线包
  • 使用 npm install -g 全局安装
  • 无需 root 权限（用户级别全局安装）
  • 简单的安装/卸载管理
  • 支持 Bash/Zsh 和 Csh/Tcsh 环境配置

示例:
  ./install_claude_code_router.sh

EOF
}

# ==================== 环境检查 ====================
check_prerequisites() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 检查环境要求              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        log_error "未找到 Node.js，安装失败"
        echo -e "${YELLOW}请先安装 Node.js 16.0.0 或更高版本${NC}"
        echo "  参考: https://nodejs.org/zh-cn/"
        return 1
    fi
    
    local node_version
    node_version=$(node --version 2>/dev/null || echo "Unknown")
    log_success "Node.js 已安装: $node_version"
    
    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "未找到 npm，安装失败"
        echo -e "${YELLOW}请先使用以下脚本安装 Node.js:${NC}"
        echo "  ./scripts/install_nodejs.sh"
        return 1
    fi
    
    local npm_version
    npm_version=$(npm --version 2>/dev/null || echo "Unknown")
    log_success "npm 已安装: $npm_version"
    
    echo ""
    return 0
}

# 检查现有安装
check_existing_installation() {
    local pkg_name="@musistudio/claude-code-router"
    
    if npm list -g "$pkg_name" &> /dev/null; then
        local installed_version
        installed_version=$(npm list -g "$pkg_name" 2>/dev/null | grep "$pkg_name" | head -1 | awk '{print $2}')
        log_success "检测到已安装: $pkg_name@$installed_version"
        return 0
    fi
    
    log_info "未检测到已安装的 Claude Code Router"
    return 1
}

# ==================== 交互式输入函数 ====================
# 选择离线包
prompt_package_path() {
    local default_pkg=""
    local user_input=""
    
    # 在 packages 目录下寻找 Claude Code Router 包
    if [ -d "$DEFAULT_PKG_DIR" ]; then
        default_pkg=$(find "$DEFAULT_PKG_DIR" -maxdepth 2 -type f \( \
            -name "musistudio-claude-code-router-*.tgz" \
            -o -name "musistudio-claude-code-router-*.tar.gz" \
            -o -name "@musistudio-claude-code-router-*.tgz" \
        \) 2>/dev/null | sort -rV | head -1)
    fi
    
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 3: 选择离线包                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if [ -n "$default_pkg" ]; then
        echo -e "  ${YELLOW}找到离线包:${NC}"
        echo "    $(basename "$default_pkg")"
        read -p "  使用此文件? (Y/n): " -n 1 -r user_input
        echo
        
        if [[ -z "$user_input" || $user_input =~ ^[Yy]$ ]]; then
            PKG_PATH="$default_pkg"
            log_info "使用离线包: $(basename "$default_pkg")"
            return 0
        fi
    fi
    
    echo -e "  ${YELLOW}包目录:${NC} $DEFAULT_PKG_DIR"
    read -p "  输入离线包路径: " user_input
    
    if [ -z "$user_input" ]; then
        log_error "必须指定离线包路径"
        return 1
    fi
    
    PKG_PATH="$user_input"
    
    # 展开波浪号
    PKG_PATH="${PKG_PATH/#\~/$HOME}"
    
    if [ ! -f "$PKG_PATH" ]; then
        log_error "文件不存在: $PKG_PATH"
        return 1
    fi
    
    log_info "使用离线包: $PKG_PATH"
    return 0
}

# 确认安装
confirm_installation() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 4: 确认安装                  │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}离线包:${NC} $PKG_PATH"
    echo -e "  ${YELLOW}安装方式:${NC} npm install -g <package>"
    echo ""
    
    if ! confirm_action "确认开始安装?"; then
        log_warn "安装已取消"
        return 1
    fi
    
    return 0
}

# ==================== 安装/卸载/管理功能 ====================
# 安装 Claude Code Router
install_router() {
    if [ -z "$PKG_PATH" ]; then
        log_error "必须指定离线包路径"
        return 1
    fi

    if [ ! -f "$PKG_PATH" ]; then
        log_error "离线包不存在: $PKG_PATH"
        return 1
    fi

    if ! confirm_installation; then
        return 1
    fi

    log_info "开始安装 Claude Code Router..."

    # 执行 npm install
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 5: 执行 npm 安装             │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    log_info "执行: npm install -g \"$PKG_PATH\""
    
    if npm install -g "$PKG_PATH" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "npm 安装完成"
    else
        log_error "npm 安装失败"
        return 1
    fi
    
    # 验证安装
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 6: 验证安装                  │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if command -v ccr &> /dev/null; then
        local ccr_version
        ccr_version=$(ccr --version 2>/dev/null || echo "Unknown")
        log_success "Claude Code Router 已安装成功"
        log_success "命令别名: ccr"
        log_success "版本: $ccr_version"
    elif command -v claude-code-router &> /dev/null; then
        local router_version
        router_version=$(claude-code-router --version 2>/dev/null || echo "Unknown")
        log_success "Claude Code Router 已安装成功"
        log_success "版本: $router_version"
    else
        log_error "安装验证失败：找不到 ccr 或 claude-code-router 命令"
        log_warn "请检查 npm global bin 目录是否在 PATH 中"
        return 1
    fi
    
    # 显示后续信息
    show_install_info
}

# 卸载 Claude Code Router
uninstall_router() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code Router 卸载          ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""

    # 检查是否存在安装
    if ! npm list -g "@musistudio/claude-code-router" &> /dev/null; then
        log_warn "未检测到已安装的 Claude Code Router"
        log_info "可能未通过 npm 安装或已卸载"
        return 1
    fi

    local pkg_version
    pkg_version=$(npm list -g "@musistudio/claude-code-router" 2>/dev/null | grep "@musistudio" | head -1 | awk '{print $2}')

    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检测到安装信息                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}包名:${NC} @musistudio/claude-code-router"
    echo -e "  ${YELLOW}版本:${NC} $pkg_version"
    echo ""

    if ! confirm_action "确认卸载?"; then
        log_warn "卸载已取消"
        return 1
    fi

    log_info "执行: npm uninstall -g @musistudio/claude-code-router"

    if npm uninstall -g "@musistudio/claude-code-router" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Claude Code Router 卸载成功"
    else
        log_error "npm 卸载失败"
        return 1
    fi

    # 删除环境变量配置
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  删除环境变量配置                  │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    local start_marker="# >>> Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local end_marker="# <<< Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local deleted_any=false

    # 删除 bash 配置
    local bash_config="$HOME/.bashrc"
    if grep -Fq "$start_marker" "$bash_config" 2>/dev/null; then
        log_info "检测到 Bash 环境变量配置，正在删除..."

        # 使用行号范围删除标记块（避免 marker 中正则元字符的干扰）
        local start_line end_line
        start_line=$(grep -nF "$start_marker" "$bash_config" | head -n1 | cut -d: -f1 || true)
        end_line=$(grep -nF "$end_marker" "$bash_config" | head -n1 | cut -d: -f1 || true)

        if [[ -n "$start_line" && -n "$end_line" && "$end_line" -ge "$start_line" ]]; then
            sed -i "${start_line},${end_line}d" "$bash_config"
            # 删除可能的多余空行
            sed -i '/^$/N;/^\n$/D' "$bash_config"

            log_success "Bash 环境变量配置已删除"
            echo ""
            echo -e "${YELLOW}请执行以下命令使配置生效:${NC}"
            echo "  source ~/.bashrc"
            deleted_any=true
        else
            log_info "未找到完整的 Bash 环境变量标记块，跳过自动删除"
        fi
    fi

    # 删除 csh 配置
    for csh_config in "$HOME/.cshrc" "$HOME/.login"; do
        if [ -f "$csh_config" ] && grep -Fq "$start_marker" "$csh_config" 2>/dev/null; then
            log_info "检测到 Csh 环境变量配置在 $csh_config，正在删除..."

            local start_line end_line
            start_line=$(grep -nF "$start_marker" "$csh_config" | head -n1 | cut -d: -f1 || true)
            end_line=$(grep -nF "$end_marker" "$csh_config" | head -n1 | cut -d: -f1 || true)

            if [[ -n "$start_line" && -n "$end_line" && "$end_line" -ge "$start_line" ]]; then
                sed -i "${start_line},${end_line}d" "$csh_config"
                sed -i '/^$/N;/^\n$/D' "$csh_config"

                log_success "Csh 环境变量配置已从 $csh_config 删除"
                deleted_any=true
            else
                log_info "未找到完整的 Csh 环境变量标记块，跳过自动删除"
            fi
        fi
    done

    if [ "$deleted_any" = false ]; then
        log_info "未找到自动配置的环境变量"
        echo ""
        echo -e "${YELLOW}提示:${NC} 如果您手动配置了环境变量，请手动删除:"
        echo "  编辑 ~/.bashrc 或 ~/.cshrc，移除包含 npm global bin 的 PATH 配置行"
    fi
}

# 检测用户默认 shell
detect_user_shell() {
    # 检查 SHELL 环境变量
    if [ -n "$SHELL" ]; then
        case "$SHELL" in
            */csh|*/tcsh)
                echo "csh"
                return 0
                ;;
            */bash)
                echo "bash"
                return 0
                ;;
            */zsh)
                echo "zsh"
                return 0
                ;;
        esac
    fi
    # 默认返回 bash
    echo "bash"
    return 0
}

# 配置环境变量到 shell 配置文件
configure_env_variables() {
    local npm_bin_dir
    npm_bin_dir=$(npm bin -g 2>/dev/null)

    if [ -z "$npm_bin_dir" ]; then
        log_warn "无法获取 npm global bin 目录"
        return 1
    fi

    local user_shell
    user_shell=$(detect_user_shell)

    log_info "检测到当前 shell: $SHELL"
    log_info "npm global bin 目录: $npm_bin_dir"

    local configured_any=false

    # 配置 bash/zsh
    local bash_config="$HOME/.bashrc"
    local bash_start_marker="# >>> Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local bash_end_marker="# <<< Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local bash_env_line="export PATH=\"$npm_bin_dir:\$PATH\""

    if [[ "$user_shell" =~ (bash|zsh) ]] || confirm_action "是否配置 bash/zsh 环境变量?"; then
        # 检查是否已存在配置
        if grep -Fq "$bash_start_marker" "$bash_config" 2>/dev/null; then
            log_warn "Bash 环境变量已配置，跳过"
        else
            log_info "添加环境变量到 $bash_config"

            # 添加带注释标记的环境变量
            {
                echo ""
                echo "$bash_start_marker"
                echo "$bash_env_line"
                echo "$bash_end_marker"
            } >> "$bash_config"

            log_success "Bash 环境变量已配置"
            configured_any=true
        fi
    fi

    # 配置 csh/tcsh
    local csh_config="$HOME/.cshrc"
    local csh_config_user="$HOME/.login"
    local csh_start_marker="# >>> Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local csh_end_marker="# <<< Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local csh_env_line="setenv PATH \"$npm_bin_dir:\$PATH\""

    if [[ "$user_shell" == "csh" ]] || confirm_action "是否配置 csh/tcsh 环境变量?"; then
        # 优先使用 .cshrc，如果不存在则检查 .login
        local target_csh_config=""
        if [ -f "$csh_config" ]; then
            target_csh_config="$csh_config"
        elif [ -f "$csh_config_user" ]; then
            target_csh_config="$csh_config_user"
        else
            # 默认使用 .cshrc
            target_csh_config="$csh_config"
        fi

        # 检查是否已存在配置
        if grep -Fq "$csh_start_marker" "$target_csh_config" 2>/dev/null; then
            log_warn "Csh 环境变量已配置，跳过"
        else
            log_info "添加环境变量到 $target_csh_config"

            # 添加带注释标记的环境变量
            {
                echo ""
                echo "$csh_start_marker"
                echo "$csh_env_line"
                echo "$csh_end_marker"
            } >> "$target_csh_config"

            log_success "Csh 环境变量已配置到 $target_csh_config"
            configured_any=true
        fi
    fi

    if [ "$configured_any" = true ]; then
        echo ""
        echo -e "${YELLOW}重要提示:${NC}"
        echo -e "  请勿在以下标记之间添加或修改内容："
        echo -e "  ${CYAN}$bash_start_marker${NC}"
        echo -e "  ${CYAN}$bash_end_marker${NC}"
        echo -e "  ${CYAN}$csh_start_marker${NC}"
        echo -e "  ${CYAN}$csh_end_marker${NC}"
        echo -e "  卸载时将自动删除这些标记之间的所有内容"
        echo ""
    fi

    return 0
}

# 显示安装信息
show_install_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  安装完成                         │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_success "Claude Code Router 已成功安装"

    echo ""
    echo -e "${YELLOW}快速开始:${NC}"
    echo "  • 查看版本: ccr --version 或 claude-code-router --version"
    echo "  • 查看帮助: ccr --help 或 claude-code-router --help"
    echo ""

    # 检查命令是否在 PATH 中
    if ! command -v ccr &>/dev/null && ! command -v claude-code-router &>/dev/null; then
        local npm_bin_dir
        npm_bin_dir=$(npm bin -g 2>/dev/null)
        echo -e "${YELLOW}注意:${NC} npm global bin 目录未在 PATH 中"
        echo ""

        if confirm_action "是否自动配置环境变量?"; then
            configure_env_variables
            echo ""
            echo -e "${YELLOW}请执行以下命令使配置生效:${NC}"
            echo "   Bash/Zsh: source ~/.bashrc"
            echo "   Csh/Tcsh: source ~/.cshrc"
            echo ""
        else
            echo -e "${YELLOW}手动配置环境变量:${NC}"
            echo ""
            echo "   Bash/Zsh:"
            echo "   echo 'export PATH=\"$npm_bin_dir:\$PATH\"' >> ~/.bashrc"
            echo "   source ~/.bashrc"
            echo ""
            echo "   Csh/Tcsh:"
            echo "   echo 'setenv PATH \"$npm_bin_dir:\$PATH\"' >> ~/.cshrc"
            echo "   source ~/.cshrc"
            echo ""
        fi
    fi

    echo -e "${YELLOW}安装日志:${NC}"
    echo "  $LOG_FILE"
    echo ""
}

# ==================== 主函数 ====================
main() {
    # 初始化日志
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/claude_code_router_install.log"

    # 显示帮助信息（如果有参数）
    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    # 显示帮助标题
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code Router 管理工具      ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    
    # 选择操作模式
    echo -e "${YELLOW}请选择操作:${NC}"
    echo ""
    echo "  1. 安装 Claude Code Router"
    echo "  2. 卸载 Claude Code Router"
    echo "  0. 退出"
    echo ""
    
    read -p "  请输入选择 (0-2): " mode_choice
    echo ""
    
    case "$mode_choice" in
        1)
            # ========== 安装模式 ==========
            # 检查环境要求
            if ! check_prerequisites; then
                exit 1
            fi
            
            # 检查现有安装
            echo ""
            echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
            echo -e "${CYAN}│  步骤 2: 检查现有安装              │${NC}"
            echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
            echo ""
            
            if check_existing_installation; then
                echo ""
                if ! confirm_action "已安装，是否继续安装新版本?"; then
                    log_warn "安装已取消"
                    exit 1
                fi
            fi
            
            # 选择离线包
            if ! prompt_package_path; then
                exit 1
            fi
            
            # 执行安装
            if ! install_router; then
                exit 1
            fi
            
            echo ""
            log_success "安装完成！安装日志: $LOG_FILE"
            ;;
        2)
            # ========== 卸载模式 ==========
            if uninstall_router; then
                echo ""
                log_success "卸载完成！安装日志: $LOG_FILE"
            else
                exit 1
            fi
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
