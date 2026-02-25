#!/bin/bash

################################################################################
# Claude Code 离线包获取脚本
# 功能：在有网络的机器上下载 Claude Code 官方二进制，打包为离线安装包
# 使用: ./fetch_claude_code.sh
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
LOG_FILE="/tmp/fetch_claude_code_$(date +%s).log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../packages"
GCS_BASE="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

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

download_file() {
    local url="$1"
    local output="$2"
    if command -v curl &>/dev/null; then
        if [ -n "$output" ]; then
            curl -fsSL -o "$output" "$url"
        else
            curl -fsSL "$url"
        fi
    elif command -v wget &>/dev/null; then
        if [ -n "$output" ]; then
            wget -q -O "$output" "$url"
        else
            wget -q -O - "$url"
        fi
    else
        log_error "需要 curl 或 wget，但均未安装"
        return 1
    fi
}

show_usage() {
    cat << EOF
${BLUE}=== Claude Code 离线包获取脚本 ===${NC}

用法:
  ./fetch_claude_code.sh

描述:
  在有网络的机器上运行，下载 Claude Code 官方预编译二进制，
  打包为可用于离线安装的 tar.gz 压缩包。

输出:
  packages/claude-code-<version>-<platform>.tar.gz

后续步骤:
  将生成的 tar.gz 文件复制到离线机器的 packages/ 目录，
  然后运行 ./scripts/install_claude_code.sh 进行安装。

EOF
}

# ==================== 检测平台 ====================
detect_platform() {
    local os arch

    case "$(uname -s)" in
        Darwin) os="darwin" ;;
        Linux)  os="linux" ;;
        *)
            log_error "不支持的操作系统: $(uname -s)"
            return 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)  arch="x64" ;;
        arm64|aarch64) arch="arm64" ;;
        *)
            log_error "不支持的架构: $(uname -m)"
            return 1
            ;;
    esac

    if [ "$os" = "linux" ]; then
        if ldd /bin/ls 2>&1 | grep -q musl; then
            echo "linux-${arch}-musl"
        else
            echo "linux-${arch}"
        fi
    else
        echo "${os}-${arch}"
    fi
}

# ==================== 步骤 1: 检查网络工具 ====================
check_prerequisites() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 1: 检查前置条件              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    if command -v curl &>/dev/null; then
        log_success "curl 已就绪: $(curl --version | head -1)"
    elif command -v wget &>/dev/null; then
        log_success "wget 已就绪: $(wget --version 2>&1 | head -1)"
    else
        log_error "需要 curl 或 wget，但均未安装"
        return 1
    fi

    # 检查 sha256sum 或 shasum
    if command -v sha256sum &>/dev/null; then
        log_success "sha256sum 已就绪"
    elif command -v shasum &>/dev/null; then
        log_success "shasum 已就绪"
    else
        log_warn "未找到 sha256sum/shasum，将跳过校验"
    fi

    return 0
}

# ==================== 步骤 2: 选择平台 ====================
prompt_platform() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 2: 选择目标平台              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    local auto_platform
    auto_platform=$(detect_platform 2>/dev/null || echo "")

    echo "  支持的平台:"
    echo "  1. linux-x64       (Linux x86_64, glibc，推荐 CentOS 7)"
    echo "  2. linux-arm64     (Linux ARM64, glibc)"
    echo "  3. linux-x64-musl  (Linux x86_64, musl/Alpine)"
    echo "  4. linux-arm64-musl(Linux ARM64, musl)"
    echo "  5. darwin-x64      (macOS Intel)"
    echo "  6. darwin-arm64    (macOS Apple Silicon)"
    echo ""

    if [ -n "$auto_platform" ]; then
        echo -e "  ${YELLOW}自动检测到当前机器平台:${NC} $auto_platform"
        read -p "  使用此平台下载? (Y/n): " -n 1 -r platform_use_auto
        echo
        if [[ -z "$platform_use_auto" || "$platform_use_auto" =~ ^[Yy]$ ]]; then
            PLATFORM="$auto_platform"
            log_info "使用平台: $PLATFORM"
            return 0
        fi
    fi

    read -p "  请输入平台编号或名称（默认 1 linux-x64）: " platform_input
    platform_input="${platform_input:-1}"

    case "$platform_input" in
        1|linux-x64)       PLATFORM="linux-x64" ;;
        2|linux-arm64)     PLATFORM="linux-arm64" ;;
        3|linux-x64-musl)  PLATFORM="linux-x64-musl" ;;
        4|linux-arm64-musl)PLATFORM="linux-arm64-musl" ;;
        5|darwin-x64)      PLATFORM="darwin-x64" ;;
        6|darwin-arm64)    PLATFORM="darwin-arm64" ;;
        *)
            log_error "无效选择: $platform_input"
            return 1
            ;;
    esac

    log_info "使用平台: $PLATFORM"
}

# ==================== 步骤 3: 选择版本 ====================
prompt_version() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 3: 选择 Claude Code 版本     │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    log_info "正在查询最新版本..."
    LATEST_VERSION=$(download_file "$GCS_BASE/latest" "" 2>/dev/null | tr -d '[:space:]')
    if [ -z "$LATEST_VERSION" ]; then
        log_warn "无法获取最新版本，将使用 stable"
        LATEST_VERSION="stable"
    fi
    log_success "最新版本: $LATEST_VERSION"
    echo ""

    read -p "  输入版本号（直接回车使用最新版 $LATEST_VERSION）: " VERSION_INPUT
    if [ -z "$VERSION_INPUT" ]; then
        CLAUDE_VERSION="$LATEST_VERSION"
    else
        CLAUDE_VERSION="$VERSION_INPUT"
    fi
    log_info "将下载版本: $CLAUDE_VERSION"
}

# ==================== 步骤 4: 下载并验证 ====================
download_and_verify() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 4: 下载二进制文件            │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    local binary_url="$GCS_BASE/$CLAUDE_VERSION/$PLATFORM/claude"
    local manifest_url="$GCS_BASE/$CLAUDE_VERSION/manifest.json"

    # 创建临时工作目录
    local work_dir
    work_dir=$(mktemp -d)
    trap "rm -rf '$work_dir'" EXIT

    local binary_file="$work_dir/claude"

    log_info "下载二进制: $binary_url"
    if ! download_file "$binary_url" "$binary_file"; then
        log_error "下载失败，请检查网络连接或版本/平台是否正确"
        return 1
    fi
    log_success "下载完成: $(du -sh "$binary_file" | cut -f1)"

    # 获取并验证 checksum
    log_info "获取校验和..."
    local manifest_json
    manifest_json=$(download_file "$manifest_url" "" 2>/dev/null || echo "")

    if [ -n "$manifest_json" ]; then
        # 从 manifest JSON 中提取 checksum（纯 bash）
        local expected_checksum=""
        manifest_json=$(echo "$manifest_json" | tr -d '\n\r\t' | sed 's/ \+/ /g')
        if [[ $manifest_json =~ \"$PLATFORM\"[^\}]*\"checksum\"[[:space:]]*:[[:space:]]*\"([a-f0-9]{64})\" ]]; then
            expected_checksum="${BASH_REMATCH[1]}"
        fi

        if [ -n "$expected_checksum" ]; then
            log_info "验证 SHA256 校验和..."
            local actual_checksum=""
            if command -v sha256sum &>/dev/null; then
                actual_checksum=$(sha256sum "$binary_file" | cut -d' ' -f1)
            elif command -v shasum &>/dev/null; then
                actual_checksum=$(shasum -a 256 "$binary_file" | cut -d' ' -f1)
            fi

            if [ -n "$actual_checksum" ]; then
                if [ "$actual_checksum" = "$expected_checksum" ]; then
                    log_success "校验和验证通过"
                else
                    log_error "校验和验证失败！文件可能已损坏"
                    log_error "期望: $expected_checksum"
                    log_error "实际: $actual_checksum"
                    return 1
                fi
            fi
        else
            log_warn "未找到平台 $PLATFORM 的校验和，跳过验证"
        fi
    else
        log_warn "无法获取 manifest，跳过校验和验证"
    fi

    chmod +x "$binary_file"

    # ==================== 步骤 5: 打包 ====================
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  步骤 5: 创建离线安装包            │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""

    mkdir -p "$OUTPUT_DIR"
    BUNDLE_NAME="claude-code-${CLAUDE_VERSION}-${PLATFORM}"
    OUTPUT_FILE="${OUTPUT_DIR}/${BUNDLE_NAME}.tar.gz"

    # 组织目录结构
    local bundle_dir="$work_dir/$BUNDLE_NAME"
    mkdir -p "$bundle_dir/bin"
    cp "$binary_file" "$bundle_dir/bin/claude"
    echo "$CLAUDE_VERSION" > "$bundle_dir/VERSION"
    echo "$PLATFORM" > "$bundle_dir/PLATFORM"

    log_info "打包中..."
    tar -czf "$OUTPUT_FILE" -C "$work_dir" "$BUNDLE_NAME"

    local size
    size=$(du -sh "$OUTPUT_FILE" | cut -f1)
    log_success "离线包已创建: $OUTPUT_FILE ($size)"
}

# ==================== 主函数 ====================
main() {
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/fetch_claude_code.log"

    if [[ $# -gt 0 ]]; then
        show_usage
        exit 0
    fi

    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude Code 离线包获取工具        ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${YELLOW}说明:${NC} 本脚本需要在有网络连接的机器上运行"
    echo -e "  ${YELLOW}输出:${NC} packages/ 目录下的 tar.gz 文件"
    echo ""

    check_prerequisites || exit 1
    prompt_platform      || exit 1
    prompt_version

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  确认下载信息                      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}版本:${NC}     $CLAUDE_VERSION"
    echo -e "  ${YELLOW}平台:${NC}     $PLATFORM"
    echo -e "  ${YELLOW}输出目录:${NC} $OUTPUT_DIR"
    echo ""

    if ! confirm_action "确认开始下载?"; then
        log_warn "操作已取消"
        exit 0
    fi

    download_and_verify || exit 1

    echo ""
    echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  下载完成！                        ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}离线包:${NC} $OUTPUT_FILE"
    echo ""
    echo -e "${YELLOW}后续步骤:${NC}"
    echo "  1. 将上述 tar.gz 文件复制到离线机器的 packages/ 目录"
    echo "  2. 在离线机器上运行:"
    echo "     chmod +x scripts/install_claude_code.sh"
    echo "     ./scripts/install_claude_code.sh"
    echo ""
    echo -e "  ${YELLOW}日志:${NC} $LOG_FILE"
    echo ""
}

main "$@"
