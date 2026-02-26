#!/bin/bash

################################################################################
# Claude Code npm 打包脚本
# 功能：从 npm 官方源下载并打包 Claude Code 为离线安装包
# 输出：packages/anthropic-claude-code-*.tgz
# 使用: ./scripts/pack_claude_code_npm.sh
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="${SCRIPT_DIR}/../packages"
LOG_FILE="/tmp/pack_claude_code_npm_$(date +%s).log"
WORK_DIR="/tmp/claude_code_npm_pack_$$"
NPM_PACKAGE="@anthropic-ai/claude-code"

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

# 清理临时目录
cleanup() {
    if [ -d "$WORK_DIR" ]; then
        log_info "清理临时目录..."
        rm -rf "$WORK_DIR"
    fi
}

trap cleanup EXIT

# 显示使用说明
show_usage() {
    cat << EOF
${BLUE}=== Claude Code npm 打包脚本 ===${NC}

用法:
  ./scripts/pack_claude_code_npm.sh

描述:
  从 npm 官方源下载 Claude Code 并打包为离线安装包（npm tarball 格式）。

功能:
  • 检测系统 npm 工具
  • 从 npm 官方源下载最新版本
  • 自动保存到 packages/ 目录
  • 验证包完整性

示例:
  ./scripts/pack_claude_code_npm.sh

${YELLOW}输出:${NC}
  ./packages/anthropic-claude-code-<version>.tgz

${YELLOW}注意:${NC}
  此脚本生成的是 npm tarball 包，需要配合 install_claude_code.sh 的 npm 安装模式使用。

EOF
}

# ==================== 环境检查 ====================
check_prerequisites() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 检查系统环境              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    local missing_tools=()

    # 检查必需工具
    for tool in bash tar grep sed; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "缺少必需工具: ${missing_tools[*]}"
        return 1
    fi

    log_success "必需工具检查通过（bash, tar, grep, sed）"

    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装，无法继续"
        log_error "请先安装 npm: https://nodejs.org/"
        return 1
    fi

    local npm_version
    npm_version=$(npm --version 2>/dev/null || echo "unknown")
    log_info "npm 已安装: $npm_version"

    echo ""
    log_success "环境检查通过"
    return 0
}

# ==================== npm 打包 ====================
pack_via_npm() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 2: 从 npm 源下载并打包       │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_info "从 npm 官方源下载 $NPM_PACKAGE..."

    # 创建工作目录
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    # 使用 npm pack 下载 tarball
    if npm pack "$NPM_PACKAGE" 2>&1 | tee -a "$LOG_FILE"; then
        # 查找下载的 tarball
        local tarball
        tarball=$(ls -1 anthropic-ai-claude-code-*.tgz 2>/dev/null | sort -V | tail -1)

        if [ -z "$tarball" ]; then
            log_error "未找到 npm 下载的 tarball"
            return 1
        fi

        log_success "npm pack 完成: $tarball"

        # 复制到 packages 目录
        mkdir -p "$PACKAGES_DIR"
        cp "$tarball" "$PACKAGES_DIR/"
        local saved_path="$PACKAGES_DIR/$tarball"

        if [ -f "$saved_path" ]; then
            local size
            size=$(du -h "$saved_path" | cut -f1)
            log_success "包已保存: $saved_path ($size)"

            # 显示 MD5
            local md5
            md5=$(md5sum "$saved_path" 2>/dev/null | awk '{print $1}' || echo "N/A")
            echo ""
            echo -e "  ${YELLOW}文件信息:${NC}"
            echo -e "    ${YELLOW}路径:${NC} $saved_path"
            echo -e "    ${YELLOW}大小:${NC} $size"
            echo -e "    ${YELLOW}MD5:${NC} $md5"

            # 列出包内容（前15个）
            echo -e "    ${YELLOW}内容预览:${NC}"
            tar -tzf "$saved_path" 2>/dev/null | head -15 | sed 's/^/      /'
            echo ""

            return 0
        else
            log_error "文件复制失败"
            return 1
        fi
    else
        log_error "npm pack 失败"
        return 1
    fi
}

# ==================== 显示总结 ====================
show_summary() {
    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  打包完成                           ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${YELLOW}后续步骤:${NC}"
    echo ""
    echo "  1. 验证离线包:"
    echo "     ls -lh $PACKAGES_DIR/anthropic-claude-code-*.tgz"
    echo ""
    echo "  2. 转移到离线环境（可选）:"
    echo "     cp $PACKAGES_DIR/anthropic-claude-code-*.tgz /path/to/offline/"
    echo ""
    echo "  3. 安装 Claude Code（选择 npm 模式）:"
    echo "     ./scripts/install_claude_code.sh"
    echo ""
    echo -e "${YELLOW}注意:${NC} npm 安装模式需要 Node.js 环境"
    echo ""
}

# ==================== 主函数 ====================
main() {
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/pack_claude_code_npm.log"

    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code npm 打包工具          ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"

    # 检查环境
    if ! check_prerequisites; then
        exit 1
    fi

    # 执行打包
    if ! pack_via_npm; then
        log_error "打包失败"
        exit 1
    fi

    # 显示总结
    show_summary

    log_success "打包流程完成"
}

main "$@"
