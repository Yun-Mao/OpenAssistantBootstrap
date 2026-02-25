#!/bin/bash

################################################################################
# Patch 工具安装脚本 - CentOS 7 / Linux
# 功能：安装 patchelf 与 glibc 2.31（离线包）
# 使用: ./install_patch_tools.sh
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
LOG_FILE="/tmp/patch_tools_install_$(date +%s).log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"
INSTALL_BASE="$HOME/.patch-tools"
GLIBC_VERSION="2.31"
GLIBC_LINK_DIR="$HOME/.glibc"

PATCHELF_PKG=""
GLIBC_PKG=""

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

show_usage() {
    cat << EOF
${BLUE}=== Patch 工具安装脚本 ===${NC}

用法:
    ./install_patch_tools.sh

描述:
  纯交互式安装脚本，将安装 patchelf 与 glibc ${GLIBC_VERSION} 离线包。
  安装路径默认: ${INSTALL_BASE}

EOF
}

prompt_install_base() {
    local user_input=""

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 选择安装路径              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}默认路径:${NC} $INSTALL_BASE"
    read -p "  输入安装路径（直接回车使用默认）: " user_input

    if [ -n "$user_input" ]; then
        INSTALL_BASE="$user_input"
    fi

    INSTALL_BASE="${INSTALL_BASE/#\~/$HOME}"
    log_info "使用安装路径: $INSTALL_BASE"
}

prompt_package_paths() {
    local user_input=""

    PATCHELF_PKG=$(find_local_package "patchelf-*.tar.gz" "patchelf-*.tar.xz")
    if [ -z "$PATCHELF_PKG" ]; then
        PATCHELF_PKG=$(find_local_package "patchelf-*.zip" "patchelf-*.tgz")
    fi

    GLIBC_PKG=$(find_local_package "glibc-${GLIBC_VERSION}-*.tar.gz" "glibc-${GLIBC_VERSION}.tar.gz")
    if [ -z "$GLIBC_PKG" ]; then
        GLIBC_PKG=$(find_local_package "glibc-${GLIBC_VERSION}-*.tar.xz" "glibc-${GLIBC_VERSION}.tar.xz")
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 2: 选择离线包                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if [ -n "$PATCHELF_PKG" ]; then
        echo -e "  ${YELLOW}检测到 patchelf 包:${NC} $(basename "$PATCHELF_PKG")"
    fi
    if [ -n "$GLIBC_PKG" ]; then
        echo -e "  ${YELLOW}检测到 glibc 包:${NC} $(basename "$GLIBC_PKG")"
    fi

    if [ -z "$PATCHELF_PKG" ]; then
        echo -e "  ${YELLOW}未找到 patchelf 离线包${NC}"
        read -p "  请输入 patchelf 包路径: " user_input
        if [ -z "$user_input" ]; then
            log_error "必须指定 patchelf 包路径"
            return 1
        fi
        PATCHELF_PKG="${user_input/#\~/$HOME}"
    fi

    if [ -z "$GLIBC_PKG" ]; then
        echo -e "  ${YELLOW}未找到 glibc 离线包${NC}"
        read -p "  请输入 glibc 包路径: " user_input
        if [ -z "$user_input" ]; then
            log_error "必须指定 glibc 包路径"
            return 1
        fi
        GLIBC_PKG="${user_input/#\~/$HOME}"
    fi

    if [ ! -f "$PATCHELF_PKG" ]; then
        log_error "patchelf 包不存在: $PATCHELF_PKG"
        return 1
    fi
    if [ ! -f "$GLIBC_PKG" ]; then
        log_error "glibc 包不存在: $GLIBC_PKG"
        return 1
    fi

    return 0
}

confirm_installation_info() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 3: 确认安装信息              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}安装路径:${NC} $INSTALL_BASE"
    echo -e "  ${YELLOW}patchelf 包:${NC} $PATCHELF_PKG"
    echo -e "  ${YELLOW}glibc 包:${NC} $GLIBC_PKG"
    echo ""

    if ! confirm_action "确认开始安装?"; then
        log_warn "安装已取消"
        return 1
    fi
    return 0
}

install_patchelf() {
    local temp_dir extracted_dir found_bin

    temp_dir=$(mktemp -d)
    if ! extract_package "$PATCHELF_PKG" "$temp_dir"; then
        log_error "patchelf 包格式不支持: $PATCHELF_PKG"
        rm -rf "$temp_dir"
        return 1
    fi

    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "patchelf 包解压失败"
        rm -rf "$temp_dir"
        return 1
    fi

    found_bin=$(find "$extracted_dir" -type f -name "patchelf" -perm -u+x | head -1)
    if [ -z "$found_bin" ]; then
        log_error "patchelf 包中未找到可执行文件"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$INSTALL_BASE/patchelf/bin"
    cp "$found_bin" "$INSTALL_BASE/patchelf/bin/patchelf"
    chmod 755 "$INSTALL_BASE/patchelf/bin/patchelf"
    rm -rf "$temp_dir"

    log_success "patchelf 已安装到: $INSTALL_BASE/patchelf/bin/patchelf"
}

install_glibc() {
    local temp_dir extracted_dir target_dir

    temp_dir=$(mktemp -d)
    if ! extract_package "$GLIBC_PKG" "$temp_dir"; then
        log_error "glibc 包格式不支持: $GLIBC_PKG"
        rm -rf "$temp_dir"
        return 1
    fi

    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "glibc 包解压失败"
        rm -rf "$temp_dir"
        return 1
    fi

    target_dir="$INSTALL_BASE/glibc-${GLIBC_VERSION}"
    rm -rf "$target_dir"
    mv "$extracted_dir" "$target_dir"
    rm -rf "$temp_dir"

    # 创建软链：$HOME/.glibc/lib -> $target_dir/lib
    mkdir -p "$GLIBC_LINK_DIR"
    rm -f "$GLIBC_LINK_DIR/lib"
    ln -s "$target_dir/lib" "$GLIBC_LINK_DIR/lib"
    log_info "创建软链: $GLIBC_LINK_DIR/lib -> $target_dir/lib"

    if [ ! -f "$target_dir/lib/ld-linux-x86-64.so.2" ]; then
        log_error "glibc 目录缺少加载器: $target_dir/lib/ld-linux-x86-64.so.2"
        return 1
    fi

    log_success "glibc ${GLIBC_VERSION} 已安装到: $target_dir"
    log_success "软链已创建到: $GLIBC_LINK_DIR/lib"
}

main() {
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/patch_tools_install.log"

    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Patch 工具安装                    ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""

    prompt_install_base
    prompt_package_paths || exit 1
    confirm_installation_info || exit 1

    if [ -d "$INSTALL_BASE" ]; then
        log_warn "安装路径已存在: $INSTALL_BASE"
        if ! confirm_action "是否覆盖现有工具?"; then
            log_warn "安装已取消"
            exit 1
        fi
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 4: 安装 patchelf             │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    install_patchelf

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 5: 安装 glibc                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    install_glibc

    echo ""
    log_success "patch 工具安装完成"
    echo -e "  ${YELLOW}patchelf:${NC} $INSTALL_BASE/patchelf/bin/patchelf"
    echo -e "  ${YELLOW}glibc:${NC} $INSTALL_BASE/glibc-${GLIBC_VERSION}"
    echo -e "  ${YELLOW}日志:${NC} $LOG_FILE"
}

main "$@"
