#!/bin/bash

################################################################################
# Claude Code 离线安装脚本 - CentOS 7 / Linux
# 功能：自定义路径安装、交互式输入、现有版本检测
# 无需 Node.js —— Claude Code 官方提供独立预编译二进制
# 使用: ./install_claude_code.sh
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
LOG_FILE="/tmp/claude_code_install_$(date +%s).log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"
INSTALL_RECORD="$HOME/.claude_code_install_record"
INSTALL_MODE=""
NPM_PKG_NAME="@anthropic-ai/claude-code"
PATCH_TOOLS_DIR="$HOME/.patch-tools"
GLIBC_VERSION="2.31"
GLIBC_DIR="${PATCH_TOOLS_DIR}/glibc-${GLIBC_VERSION}"
GLIBC_LINK_DIR="$HOME/.glibc"
GLIBC_LIB="${GLIBC_LINK_DIR}/lib"
case "$(uname -m)" in
    x86_64)        GLIBC_INTERPRETER="${GLIBC_LIB}/ld-linux-x86-64.so.2" ;;
    aarch64|arm64) GLIBC_INTERPRETER="${GLIBC_LIB}/ld-linux-aarch64.so.1" ;;
    *)             GLIBC_INTERPRETER="" ;;
esac
PATCHELF_DIR="${PATCH_TOOLS_DIR}/patchelf"
PATCHELF_BIN="${PATCHELF_DIR}/bin/patchelf"
CLAUDE_PATCHED="no"

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

confirm_action() {
    local prompt="$1"
    read -p "  $(echo -e "${YELLOW}")${prompt}$(echo -e "${NC}") (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

find_local_package() {
    local name_pattern_1="$1"
    local name_pattern_2="$2"

    if [ -d "$DEFAULT_PKG_DIR" ]; then
        find "$DEFAULT_PKG_DIR" -maxdepth 2 -type f \( -name "$name_pattern_1" -o -name "$name_pattern_2" \) 2>/dev/null | sort -r | head -1
    fi
}

extract_package() {
    local pkg_path="$1"
    local dest_dir="$2"

    case "$pkg_path" in
        *.tar.gz|*.tgz)
            tar -xzf "$pkg_path" -C "$dest_dir"
            ;;
        *.tar.xz)
            tar -xJf "$pkg_path" -C "$dest_dir"
            ;;
        *.zip)
            unzip -q "$pkg_path" -d "$dest_dir"
            ;;
        *)
            return 1
            ;;
    esac
}

detect_glibc_version() {
    if command -v getconf &>/dev/null; then
        getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}'
        return 0
    fi

    if command -v ldd &>/dev/null; then
        ldd --version 2>/dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+'
        return 0
    fi

    echo ""
}

claude_needs_patch() {
    local claude_bin="$INSTALL_PATH/bin/claude"
    local output
    local status

    if [ ! -x "$claude_bin" ]; then
        return 1
    fi

    set +e
    output=$("$claude_bin" --version 2>&1)
    status=$?
    set -e
    if [ $status -eq 0 ]; then
        return 1
    fi

    if echo "$output" | grep -q "GLIBC_"; then
        return 0
    fi

    if echo "$output" | grep -qi "not found"; then
        return 0
    fi

    if command -v ldd &>/dev/null; then
        if ldd "$claude_bin" 2>&1 | grep -q "GLIBC_"; then
            return 0
        fi
        if ldd "$claude_bin" 2>&1 | grep -qi "not found"; then
            return 0
        fi
    fi

    return 1
}

ensure_patchelf() {
    if command -v patchelf &>/dev/null; then
        PATCHELF_BIN="$(command -v patchelf)"
        return 0
    fi

    if [ -x "$PATCHELF_BIN" ]; then
        return 0
    fi

    local pkg_path
    pkg_path=$(find_local_package "patchelf-*.tar.gz" "patchelf-*.tar.xz")
    if [ -z "$pkg_path" ]; then
        pkg_path=$(find_local_package "patchelf-*.zip" "patchelf-*.tgz")
    fi

    if [ -z "$pkg_path" ]; then
        log_error "未找到 patchelf 离线包，请放入 packages/ 目录"
        return 1
    fi

    log_info "检测到 patchelf 离线包: $(basename "$pkg_path")"

    local temp_dir
    temp_dir=$(mktemp -d)
    if ! extract_package "$pkg_path" "$temp_dir"; then
        log_error "patchelf 离线包格式不支持: $pkg_path"
        rm -rf "$temp_dir"
        return 1
    fi

    local extracted_dir
    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "patchelf 离线包解压失败"
        rm -rf "$temp_dir"
        return 1
    fi

    local found_bin
    found_bin=$(find "$extracted_dir" -type f -name "patchelf" -perm -u+x | head -1)
    if [ -z "$found_bin" ]; then
        log_error "patchelf 离线包中未找到可执行文件"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$PATCHELF_DIR/bin"
    cp "$found_bin" "$PATCHELF_BIN"
    chmod 755 "$PATCHELF_BIN"
    rm -rf "$temp_dir"
    log_success "patchelf 已安装到: $PATCHELF_BIN"
    return 0
}

ensure_glibc() {
    if [ -f "$GLIBC_INTERPRETER" ]; then
        return 0
    fi

    local pkg_path
    pkg_path=$(find_local_package "glibc-${GLIBC_VERSION}-*.tar.gz" "glibc-${GLIBC_VERSION}.tar.gz")
    if [ -z "$pkg_path" ]; then
        pkg_path=$(find_local_package "glibc-${GLIBC_VERSION}-*.tar.xz" "glibc-${GLIBC_VERSION}.tar.xz")
    fi

    if [ -z "$pkg_path" ]; then
        log_error "未找到 glibc ${GLIBC_VERSION} 离线包，请放入 packages/ 目录"
        return 1
    fi

    log_info "检测到 glibc ${GLIBC_VERSION} 离线包: $(basename "$pkg_path")"

    local temp_dir
    temp_dir=$(mktemp -d)
    if ! extract_package "$pkg_path" "$temp_dir"; then
        log_error "glibc 离线包格式不支持: $pkg_path"
        rm -rf "$temp_dir"
        return 1
    fi

    local extracted_dir
    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "glibc 离线包解压失败"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$PATCH_TOOLS_DIR"
    rm -rf "$GLIBC_DIR"
    mv "$extracted_dir" "$GLIBC_DIR"
    rm -rf "$temp_dir"

    # 创建软链：$HOME/.glibc/lib -> $GLIBC_DIR/lib
    mkdir -p "$GLIBC_LINK_DIR"
    if [ -e "$GLIBC_LINK_DIR/lib" ] || [ -L "$GLIBC_LINK_DIR/lib" ]; then
        if [ -d "$GLIBC_LINK_DIR/lib" ] && [ ! -L "$GLIBC_LINK_DIR/lib" ]; then
            rm -rf "$GLIBC_LINK_DIR/lib"
        else
            rm -f "$GLIBC_LINK_DIR/lib"
        fi
    fi
    ln -s "$GLIBC_DIR/lib" "$GLIBC_LINK_DIR/lib"
    log_info "创建软链: $GLIBC_LINK_DIR/lib -> $GLIBC_DIR/lib"

    if [ ! -f "$GLIBC_INTERPRETER" ]; then
        log_error "glibc 目录缺少加载器: $GLIBC_INTERPRETER"
        return 1
    fi

    log_success "glibc ${GLIBC_VERSION} 已安装到: $GLIBC_DIR"
    log_success "软链已创建到: $GLIBC_LINK_DIR/lib"
    return 0
}

apply_patch_to_claude() {
    local claude_bin="$INSTALL_PATH/bin/claude"
    local patchelf_bin="$PATCHELF_BIN"

    if command -v patchelf &>/dev/null; then
        patchelf_bin="$(command -v patchelf)"
    fi

    if [ ! -x "$patchelf_bin" ]; then
        log_error "patchelf 不可用，无法执行 patch"
        return 1
    fi

    if [ ! -f "$GLIBC_INTERPRETER" ]; then
        log_error "glibc 加载器不存在: $GLIBC_INTERPRETER"
        return 1
    fi

    log_info "正在 patch Claude Code..."
    if ! "$patchelf_bin" --set-interpreter "$GLIBC_INTERPRETER" "$claude_bin"; then
        log_error "设置 interpreter 失败"
        return 1
    fi

    if ! "$patchelf_bin" --force-rpath --set-rpath "$GLIBC_LIB:/usr/lib64:/lib64" "$claude_bin"; then
        log_error "设置 rpath 失败"
        return 1
    fi

    log_success "Claude Code patch 完成"
    CLAUDE_PATCHED="yes"
    return 0
}

maybe_patch_claude() {
    local claude_bin="$INSTALL_PATH/bin/claude"
    local glibc_version

    if [ ! -x "$claude_bin" ]; then
        return 0
    fi

    if [ "$(uname -s)" != "Linux" ]; then
        log_info "非 Linux 平台，跳过 patch"
        return 0
    fi

    glibc_version=$(detect_glibc_version)
    if [ -n "$glibc_version" ]; then
        log_info "检测到系统 glibc 版本: $glibc_version"
    fi

    if ! claude_needs_patch; then
        log_info "Claude Code 可直接运行，无需 patch"
        return 0
    fi

    log_warn "检测到 Claude Code 可能需要 glibc ${GLIBC_VERSION} patch"

    if ! ensure_patchelf; then
        log_error "缺少 patchelf，跳过 patch"
        return 0
    fi

    if ! ensure_glibc; then
        log_error "缺少 glibc ${GLIBC_VERSION}，跳过 patch"
        return 0
    fi

    if ! apply_patch_to_claude; then
        log_error "Claude Code patch 失败"
        return 0
    fi

    local verify_output
    verify_output=$("$claude_bin" --version 2>&1 || true)
    if echo "$verify_output" | grep -q "Claude"; then
        log_success "patch 后验证通过: $verify_output"
    else
        log_warn "patch 后仍无法验证: $verify_output"
    fi
}

show_usage() {
    cat << EOF
${BLUE}=== Claude Code 离线安装脚本 ===${NC}

用法:
  ./install_claude_code.sh

描述:
  纯交互式安装脚本，将指引您完成 Claude Code 离线安装过程。
  支持两种安装模式：独立二进制模式（无需 Node.js）和 npm 模式。

安装模式:
  1. 独立二进制模式 - 使用官方预编译二进制，无需 Node.js
  2. npm 全局安装模式 - 使用 npm install -g，需要 Node.js 环境

功能:
  • 检测本地已有的 Claude Code 安装
  • 交互式选择安装模式
  • 自动识别 packages/ 目录中的离线安装包
  • 无需 root 权限，完全用户级别安装
  • 支持 Bash/Zsh 和 Csh/Tcsh 环境配置

示例:
  ./install_claude_code.sh

EOF
}

# ==================== 现有版本检测 ====================
check_existing_claude() {
    if command -v claude &>/dev/null; then
        claude_version=$(claude --version 2>/dev/null | head -1 || echo "未知版本")
        claude_path=$(which claude)
        return 0
    fi

    # 检查安装记录
    if [ -f "$INSTALL_RECORD" ]; then
        local recorded_path
        recorded_path=$(cat "$INSTALL_RECORD")
        if [ -x "${recorded_path}/bin/claude" ]; then
            claude_version=$("${recorded_path}/bin/claude" --version 2>/dev/null | head -1 || echo "未知版本")
            claude_path="${recorded_path}/bin/claude"
            return 0
        fi
    fi

    return 1
}

# ==================== 交互式输入函数 ====================
# 步骤 1: 询问是否已有安装
prompt_existing_install() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 检测现有 Claude Code 安装 │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if check_existing_claude; then
        log_success "检测到现有 Claude Code 安装"
        echo -e "  ${YELLOW}版本:${NC} $claude_version"
        echo -e "  ${YELLOW}路径:${NC} $claude_path"
        echo ""

        if confirm_action "是否继续安装新版本?"; then
            return 0
        else
            log_warn "安装已取消"
            return 1
        fi
    else
        log_info "未检测到现有 Claude Code 安装"
        echo ""
        if ! confirm_action "继续安装?"; then
            log_warn "安装已取消"
            return 1
        fi
        return 0
    fi
}

# 步骤 2: 交互式输入安装路径
prompt_install_path() {
    local default_path="$HOME/claude-code"
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

    INSTALL_PATH="${INSTALL_PATH/#\~/$HOME}"
}

# 步骤 3: 交互式选择离线包
prompt_package_path() {
    local default_pkg=""
    local user_input=""

    # 在 packages 目录下查找 claude-code 离线包（优先最新）
    if [ -d "$DEFAULT_PKG_DIR" ]; then
        default_pkg=$(find "$DEFAULT_PKG_DIR" -maxdepth 2 -type f -name "claude-code-*.tar.gz" 2>/dev/null | sort -r | head -1)
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 3: 选择离线安装包            │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if [ -n "$default_pkg" ]; then
        echo -e "  ${YELLOW}找到离线安装包:${NC}"
        echo "    $(basename "$default_pkg")"
        read -p "  使用此文件? (Y/n): " -n 1 -r user_input
        echo

        if [[ -z "$user_input" || "$user_input" =~ ^[Yy]$ ]]; then
            PKG_PATH="$default_pkg"
            log_info "使用离线安装包: $(basename "$default_pkg")"
            return 0
        fi
    fi

    echo -e "  ${YELLOW}默认目录:${NC} $DEFAULT_PKG_DIR"
    echo -e "  ${YELLOW}提示:${NC} 请先在有网络的机器上运行 fetch_claude_code.sh 获取离线包"
    read -p "  输入离线包路径: " user_input

    if [ -z "$user_input" ]; then
        log_error "必须指定离线包路径"
        return 1
    else
        PKG_PATH="$user_input"
        log_info "使用离线包: $PKG_PATH"
    fi

    PKG_PATH="${PKG_PATH/#\~/$HOME}"
}

# 步骤 4: 确认安装信息
confirm_installation_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 4: 确认安装信息              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}源包:${NC}     $PKG_PATH"
    echo -e "  ${YELLOW}目标路径:${NC} $INSTALL_PATH"
    echo ""

    if ! confirm_action "确认开始安装?"; then
        log_warn "安装已取消"
        return 1
    fi

    return 0
}

# ==================== 卸载功能 ====================
uninstall_claude_code() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code 卸载 - 交互式模式    ║${NC}"
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
    echo -e "${CYAN}│  删除 Claude Code 文件             │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if [ -d "$INSTALL_PATH" ]; then
        # 安全校验：禁止删除根目录或家目录
        if [[ "$INSTALL_PATH" == "/" || "$INSTALL_PATH" == "$HOME" ]]; then
            log_error "安全校验失败：不允许删除根目录或家目录 ($INSTALL_PATH)，已中止卸载"
            return 1
        fi

        # 结构校验：检查是否为 claude-code 安装目录
        if [ ! -x "$INSTALL_PATH/bin/claude" ]; then
            log_warn "安全提示：路径 '$INSTALL_PATH' 下未找到可执行的 bin/claude，看起来不像是 Claude Code 安装目录。"
            if ! confirm_action "仍然要删除该目录吗? 这可能删除与 Claude Code 无关的文件"; then
                log_error "卸载已取消"
                return 1
            fi
        fi

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

    local start_marker="# >>> Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local end_marker="# <<< Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
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
            local sed_inplace
            if sed --version >/dev/null 2>&1; then
                sed_inplace=(-i)
            else
                sed_inplace=(-i '')
            fi
            if sed "${sed_inplace[@]}" "${start_line},${end_line}d" "$bash_config" && \
               sed "${sed_inplace[@]}" '/^$/N;/^\n$/D' "$bash_config"; then
                log_success "Bash 环境变量配置已删除"
                echo ""
                echo -e "${YELLOW}请执行以下命令使配置生效:${NC}"
                echo "  source ~/.bashrc"
                deleted_any=true
            fi
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
                local sed_inplace
                if sed --version >/dev/null 2>&1; then
                    sed_inplace=(-i)
                else
                    sed_inplace=(-i '')
                fi
                sed "${sed_inplace[@]}" "${start_line},${end_line}d" "$csh_config"
                sed "${sed_inplace[@]}" '/^$/N;/^\n$/D' "$csh_config"

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
        echo "  编辑 ~/.bashrc 或 ~/.cshrc，移除包含 '$INSTALL_PATH' 的 PATH 配置行"
    fi

    echo ""
    log_info "删除安装记录..."
    rm -f "$INSTALL_RECORD"

    echo ""
    log_success "Claude Code 卸载完成!"
}

# ==================== 更新配置功能 ====================
update_config() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code 更新配置 - 交互式模式 ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""

    if [ ! -f "$INSTALL_RECORD" ]; then
        log_error "未找到安装记录文件: $INSTALL_RECORD"
        log_error "请先使用安装模式安装 Claude Code"
        return 1
    fi

    INSTALL_PATH=$(cat "$INSTALL_RECORD")

    if [ ! -d "$INSTALL_PATH" ]; then
        log_error "安装路径不存在: $INSTALL_PATH"
        log_error "请重新安装 Claude Code"
        return 1
    fi

    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检测到安装信息                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}安装路径:${NC} $INSTALL_PATH"

    local claude_bin="$INSTALL_PATH/bin/claude"
    if [[ -x "$claude_bin" ]]; then
        local ver
        ver=$("$claude_bin" --version 2>/dev/null | head -1 || echo "未知版本")
        echo -e "  ${YELLOW}版本:${NC} $ver"
    else
        echo -e "  ${YELLOW}警告:${NC} 未在 $claude_bin 找到可执行文件"
    fi

    if [ -f "$INSTALL_PATH/PLATFORM" ]; then
        echo -e "  ${YELLOW}平台:${NC} $(cat "$INSTALL_PATH/PLATFORM")"
    fi
    echo ""

    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  配置选项                         │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo "  1. 配置环境变量"
    echo "  2. 显示完整安装信息"
    echo "  0. 返回"
    echo ""

    read -p "  请选择操作 (0-2): " choice

    case "$choice" in
        1)
            echo ""
            local bash_config="$HOME/.bashrc"
            local start_marker="# >>> Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
            if grep -q "$start_marker" "$bash_config" 2>/dev/null; then
                log_warn "环境变量已经配置过了"
            elif confirm_action "是否自动配置环境变量?"; then
                configure_env_variables
                echo ""
                echo -e "${YELLOW}请运行以下命令使配置生效:${NC}"
                echo "  Bash/Zsh: source ~/.bashrc"
                echo "  Csh/Tcsh: source ~/.cshrc"
            fi
            ;;
        2)
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

# ==================== npm 安装模式功能 ====================
# 检查 npm 环境要求
check_npm_prerequisites() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检查 npm 环境要求                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        log_error "未找到 Node.js"
        echo -e "${YELLOW}npm 安装模式需要 Node.js 16.0.0 或更高版本${NC}"
        echo "  请先安装 Node.js 或选择独立二进制模式"
        echo "  参考: https://nodejs.org/zh-cn/"
        return 1
    fi

    local node_version
    node_version=$(node --version 2>/dev/null || echo "Unknown")
    log_success "Node.js 已安装: $node_version"

    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "未找到 npm"
        echo -e "${YELLOW}请先安装 Node.js（npm 包含在 Node.js 中）${NC}"
        return 1
    fi

    local npm_version
    npm_version=$(npm --version 2>/dev/null || echo "Unknown")
    log_success "npm 已安装: $npm_version"

    echo ""
    return 0
}

# 检查现有的 npm 安装
check_existing_npm_installation() {
    if npm list -g "$NPM_PKG_NAME" &> /dev/null; then
        local installed_version
        installed_version=$(npm list -g "$NPM_PKG_NAME" 2>/dev/null | grep "$NPM_PKG_NAME" | head -1 | awk '{print $2}')
        log_success "检测到已安装（npm）: $NPM_PKG_NAME@$installed_version"
        return 0
    fi

    log_info "未检测到已安装的 Claude Code（npm 模式）"
    return 1
}

# 选择 npm 离线包
prompt_npm_package_path() {
    local default_pkg=""
    local user_input=""

    # 在 packages 目录下寻找 Claude Code npm 包
    if [ -d "$DEFAULT_PKG_DIR" ]; then
        default_pkg=$(find "$DEFAULT_PKG_DIR" -maxdepth 2 -type f \( \
            -name "anthropic-claude-code-*.tgz" \
            -o -name "anthropic-claude-code-*.tar.gz" \
            -o -name "@anthropic-ai-claude-code-*.tgz" \
        \) 2>/dev/null | sort -rV | head -1)
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  选择 npm 离线包                   │${NC}"
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
    echo -e "  ${YELLOW}提示:${NC} 请先在有网络的机器上运行 pack_claude_code_npm.sh 获取离线包"
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

# 确认 npm 安装
confirm_npm_installation() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  确认 npm 安装                     │${NC}"
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

# npm 安装 Claude Code
install_claude_code_npm() {
    if [ -z "$PKG_PATH" ]; then
        log_error "必须指定离线包路径"
        return 1
    fi

    if [ ! -f "$PKG_PATH" ]; then
        log_error "离线包不存在: $PKG_PATH"
        return 1
    fi

    if ! confirm_npm_installation; then
        return 1
    fi

    log_info "开始通过 npm 安装 Claude Code..."

    # 执行 npm install
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  执行 npm 安装                      │${NC}"
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
    echo -e "${CYAN}│  验证安装                           │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if command -v claude &> /dev/null; then
        local claude_version
        claude_version=$(claude --version 2>/dev/null || echo "Unknown")
        log_success "Claude Code 已安装成功"
        log_success "版本: $claude_version"

        # 保存安装记录（标记为 npm 模式）
        echo "npm" > "$INSTALL_RECORD"
        echo "$NPM_PKG_NAME" >> "$INSTALL_RECORD"
        log_info "安装记录已保存到: $INSTALL_RECORD"
    else
        log_warn "安装验证失败：找不到 claude 命令"
        log_warn "请检查 npm global bin 目录是否在 PATH 中"
        echo ""
        echo -e "${YELLOW}查看 npm 全局 bin 目录:${NC}"
        echo "  npm bin -g"
        echo ""
        echo -e "${YELLOW}如果需要，将其添加到 PATH:${NC}"
        echo "  echo 'export PATH=\"\$(npm bin -g):\$PATH\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
        echo ""
        return 1
    fi

    # 显示后续信息
    show_npm_install_info
}

# 显示 npm 安装完成信息
show_npm_install_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  安装完成                           │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_success "Claude Code 已成功安装（npm 模式）"

    echo ""
    echo -e "${YELLOW}快速开始:${NC}"
    echo "  • 查看版本: claude --version"
    echo "  • 查看帮助: claude --help"
    echo ""

    echo -e "${YELLOW}安装日志:${NC}"
    echo "  $LOG_FILE"
    echo ""
}

# npm 卸载 Claude Code
uninstall_claude_code_npm() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code 卸载（npm 模式）      ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""

    # 检查是否存在安装
    if ! npm list -g "$NPM_PKG_NAME" &> /dev/null; then
        log_warn "未检测到已安装的 Claude Code（npm 模式）"
        log_info "可能未通过 npm 安装或已卸载"
        return 1
    fi

    local pkg_version
    pkg_version=$(npm list -g "$NPM_PKG_NAME" 2>/dev/null | grep "claude-code" | head -1 | awk '{print $2}')

    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  检测到安装信息                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}包名:${NC} $NPM_PKG_NAME"
    echo -e "  ${YELLOW}版本:${NC} $pkg_version"
    echo ""

    if ! confirm_action "确认卸载?"; then
        log_warn "卸载已取消"
        return 1
    fi

    log_info "执行: npm uninstall -g $NPM_PKG_NAME"

    if npm uninstall -g "$NPM_PKG_NAME" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Claude Code 卸载成功"
        rm -f "$INSTALL_RECORD"
    else
        log_error "npm 卸载失败"
        return 1
    fi
}

# ==================== 安装功能（独立二进制模式） ====================
install_claude_code() {
    if [ -z "$INSTALL_PATH" ]; then
        log_error "必须指定安装路径"
        return 1
    fi

    if [ -z "$PKG_PATH" ]; then
        log_error "必须指定离线包路径"
        return 1
    fi

    if [ ! -f "$PKG_PATH" ]; then
        log_error "离线包不存在: $PKG_PATH"
        return 1
    fi

    if ! confirm_installation_info; then
        return 1
    fi

    log_info "开始安装 Claude Code..."

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
    echo -e "${CYAN}│  步骤 7: 解压离线安装包            │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_info "解压文件..."
    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT

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

    # ========== 步骤 8: 复制文件 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 8: 复制文件到目标路径        │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    local extracted_dir
    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "无法找到解压后的目录"
        return 1
    fi

    log_info "复制文件: $(basename "$extracted_dir") -> $INSTALL_PATH"
    cp -r "$extracted_dir"/. "$INSTALL_PATH/"
    log_success "文件复制完成"

    # 验证核心二进制
    if [ ! -f "$INSTALL_PATH/bin/claude" ]; then
        log_error "错误: 未找到 bin/claude 文件"
        log_error "请确认离线包由 fetch_claude_code.sh 生成"
        return 1
    fi

    # ========== 步骤 9: 设置权限 ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 9: 设置文件权限              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    chmod 755 "$INSTALL_PATH/bin/claude"
    log_success "权限设置完成"

    # ========== 步骤 9.5: 智能检测并 patch ==========
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 9.5: 检测是否需要 patch      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    maybe_patch_claude

    log_success "Claude Code 安装成功!"

    # 保存安装记录
    echo "$INSTALL_PATH" > "$INSTALL_RECORD"
    log_info "安装记录已保存到: $INSTALL_RECORD"

    show_install_info
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
    local user_shell
    user_shell=$(detect_user_shell)

    log_info "检测到当前 shell: $SHELL"

    local configured_any=false

    # 配置 bash/zsh
    local bash_config="$HOME/.bashrc"
    local bash_start_marker="# >>> Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local bash_end_marker="# <<< Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local bash_env_line="export PATH=\"$INSTALL_PATH/bin:\$PATH\""

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
    local csh_start_marker="# >>> Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>"
    local csh_end_marker="# <<< Claude Code Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<"
    local csh_env_line="setenv PATH \"$INSTALL_PATH/bin:\$PATH\""

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
    echo -e "${CYAN}│  步骤 10: 安装完成                 │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_success "安装路径: $INSTALL_PATH"

    local claude_bin="$INSTALL_PATH/bin/claude"
    if [[ -x "$claude_bin" ]]; then
        local ver
        ver=$("$claude_bin" --version 2>/dev/null | head -1 || echo "未知版本")
        log_success "Claude Code 版本: ${ver}"
    else
        echo -e "${YELLOW}警告: 未在 $claude_bin 找到可执行文件。${NC}"
    fi

    if [ -f "$INSTALL_PATH/PLATFORM" ]; then
        log_success "平台: $(cat "$INSTALL_PATH/PLATFORM")"
    fi

    if [ "$CLAUDE_PATCHED" = "yes" ]; then
        log_success "patch 状态: 已应用 glibc ${GLIBC_VERSION}"
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  后续配置步骤                      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
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
        echo "   echo 'export PATH=\"$INSTALL_PATH/bin:\$PATH\"' >> ~/.bashrc"
        echo "   source ~/.bashrc"
        echo ""
        echo "   Csh/Tcsh:"
        echo "   echo 'setenv PATH \"$INSTALL_PATH/bin:\$PATH\"' >> ~/.cshrc"
        echo "   source ~/.cshrc"
        echo ""
    fi

    echo -e "${YELLOW}验证安装:${NC}"
    echo "   claude --version"
    echo ""
}

# 选择安装模式
prompt_install_mode() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  选择安装模式                      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${YELLOW}Claude Code 支持两种安装模式:${NC}"
    echo ""
    echo "  1. 独立二进制模式（推荐）"
    echo "     • 无需 Node.js，使用官方预编译二进制"
    echo "     • 安装到自定义目录"
    echo "     • 支持低版本系统的 glibc patch"
    echo ""
    echo "  2. npm 全局安装模式"
    echo "     • 需要 Node.js 16+ 环境"
    echo "     • 通过 npm 全局安装"
    echo "     • 与 Node.js 生态系统集成"
    echo ""

    read -p "  请选择安装模式 (1/2, 默认 1): " mode_choice
    echo ""

    case "$mode_choice" in
        2)
            INSTALL_MODE="npm"
            log_info "选择安装模式: npm 全局安装"
            ;;
        ""|1)
            INSTALL_MODE="binary"
            log_info "选择安装模式: 独立二进制"
            ;;
        *)
            log_warn "无效选择，使用默认模式: 独立二进制"
            INSTALL_MODE="binary"
            ;;
    esac
}

# ==================== 主函数 ====================
main() {
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/claude_code_install.log"

    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code 管理工具              ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}选择操作模式:${NC}"
    echo ""
    echo "  1. 安装 Claude Code"
    echo "  2. 卸载 Claude Code"
    echo "  3. 更新配置"
    echo "  0. 退出"
    echo ""

    read -p "  请选择 (0-3): " mode_choice
    echo ""

    case "$mode_choice" in
        1)
            # 选择安装模式
            prompt_install_mode

            if [ "$INSTALL_MODE" = "npm" ]; then
                # ========== npm 安装模式 ==========
                echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║  Claude Code 安装 - npm 模式      ║${NC}"
                echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"

                # 检查 npm 环境
                if ! check_npm_prerequisites; then
                    exit 1
                fi

                # 检查现有安装
                echo ""
                echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
                echo -e "${CYAN}│  检查现有安装                      │${NC}"
                echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
                echo ""

                if check_existing_npm_installation; then
                    echo ""
                    if ! confirm_action "已安装，是否继续安装新版本?"; then
                        log_warn "安装已取消"
                        exit 1
                    fi
                fi

                # 选择离线包
                if ! prompt_npm_package_path; then
                    exit 1
                fi

                # 执行安装
                if ! install_claude_code_npm; then
                    exit 1
                fi
            else
                # ========== 独立二进制安装模式 ==========
                echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║  Claude Code 安装 - 独立二进制    ║${NC}"
                echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"

                if ! prompt_existing_install; then
                    exit 1
                fi

                prompt_install_path

                if ! prompt_package_path; then
                    exit 1
                fi

                install_claude_code
            fi
            ;;
        2)
            # 卸载模式 - 需要检测是哪种安装方式
            if [ -f "$INSTALL_RECORD" ]; then
                local first_line
                first_line=$(head -1 "$INSTALL_RECORD" 2>/dev/null || echo "")
                if [ "$first_line" = "npm" ]; then
                    uninstall_claude_code_npm
                    exit 0
                fi
            fi
            uninstall_claude_code
            ;;
        3)
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
