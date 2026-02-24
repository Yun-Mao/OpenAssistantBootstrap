#!/bin/bash

################################################################################
# OpenAssistant Bootstrap - Git工作流自动化脚本
# 功能: 自动完成feature分支创建、代码提交、PR推送、合并和清理
# 使用: ./git-workflow.sh <action> [options]
################################################################################

set -e

# ==================== 颜色定义 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== 工具函数 ====================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# ==================== 显示帮助 ====================
show_help() {
    cat << EOF
${BLUE}=== OpenAssistant Git工作流自动化 ===${NC}

用法:
  ./git-workflow.sh <action> [options]

操作:
  start <branch-name>           创建feature分支并开始开发
                                示例: ./git-workflow.sh start feat/python-installer

  submit <commit-message>       提交本地代码到远端并发起PR
                                示例: ./git-workflow.sh submit "Add Python support"

  finalize                      同步main分支并清理feature分支
                                （在PR合并后运行）

示例工作流:

  # 1. 创建feature分支
  ./git-workflow.sh start feat/python-installer

  # 2. 进行开发和提交...
  git commit -m "feat: add Python installation script"
  git commit -m "docs: add Python documentation"

  # 3. 提交到远端并发起PR
  ./git-workflow.sh submit "Add Python offline installation tool"

  # 4. 在GitHub上进行Code Review和合并

  # 5. 同步和清理
  ./git-workflow.sh finalize

EOF
}

# ==================== 获取当前分支 ====================
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# ==================== 检查git状态 ====================
check_git_status() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "不是一个git仓库"
    fi
}

# ==================== 创建feature分支 ====================
start_feature() {
    local branch_name="$1"
    
    if [ -z "$branch_name" ]; then
        log_error "请指定分支名称，格式: feat/<feature-name>"
    fi
    
    check_git_status
    
    log_info "开始创建feature分支..."
    
    # 确保main分支是最新的
    log_info "更新main分支..."
    git fetch origin
    git checkout main
    git pull origin main
    
    # 创建feature分支
    log_info "创建分支: $branch_name"
    git checkout -b "$branch_name"
    
    log_success "✨ Feature分支已创建: $branch_name"
    echo ""
    echo -e "${CYAN}下一步:${NC}"
    echo "1. 进行代码开发和修改"
    echo "2. 进行git提交: git commit -m \"<message>\""
    echo "3. 当完成后运行: ./git-workflow.sh submit \"<功能描述>\""
    echo ""
}

# ==================== 提交代码到远端并发起PR ====================
submit_code() {
    local pr_title="$1"
    
    if [ -z "$pr_title" ]; then
        log_error "请提供PR标题，例如: ./git-workflow.sh submit \"Add Python support\""
    fi
    
    check_git_status
    
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" == "main" ]; then
        log_error "当前在main分支上，请切换到feature分支"
    fi
    
    log_info "当前分支: $current_branch"
    
    # 推送到远端
    log_info "推送代码到远端..."
    git push -u origin "$current_branch"
    
    log_success "✨ 代码已推送到远端"
    echo ""
    echo -e "${CYAN}PR创建链接:${NC}"
    echo "https://github.com/Yun-Mao/OpenAssistantBootstrap/pull/new/$current_branch"
    echo ""
    echo -e "${YELLOW}提示:${NC}"
    echo "1. 访问上面的链接创建Pull Request"
    echo "2. 填写标题: $pr_title"
    echo "3. 在GitHub上进行Code Review"
    echo "4. PR合并后运行: ./git-workflow.sh finalize"
    echo ""
}

# ==================== 合并后清理 ====================
finalize() {
    check_git_status
    
    local current_branch=$(get_current_branch)
    
    log_info "开始清理工作..."
    
    # 切换到main
    log_info "切换到main分支..."
    git checkout main
    
    # 同步远端
    log_info "同步远端最新内容..."
    git fetch origin
    git pull origin main
    
    # 删除本地feature分支
    if [ "$current_branch" != "main" ]; then
        log_info "删除本地feature分支: $current_branch"
        git branch -d "$current_branch" 2>/dev/null || git branch -D "$current_branch"
        
        # 删除远端追踪
        log_info "删除远端追踪分支..."
        git branch -D -r origin/"$current_branch" 2>/dev/null || true
    fi
    
    log_success "✨ 清理完成！"
    echo ""
    log_success "当前分支: main (已同步到最新)"
    log_info "现在可以开始下一个feature开发了"
    echo ""
}

# ==================== 一键完成流程 ====================
auto_submit() {
    local feature_name="$1"
    local pr_title="$2"
    
    if [ -z "$feature_name" ] || [ -z "$pr_title" ]; then
        log_error "使用: ./git-workflow.sh auto <feat-name> \"<PR-title>\""
    fi
    
    # 创建分支
    start_feature "feat/$feature_name"
    
    log_warn "请先进行代码开发和提交，然后运行:"
    log_warn "./git-workflow.sh submit \"$pr_title\""
}

# ==================== 主函数 ====================
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    local action="$1"
    shift
    
    case "$action" in
        start)
            start_feature "$@"
            ;;
        submit)
            submit_code "$@"
            ;;
        finalize|cleanup)
            finalize
            ;;
        auto)
            auto_submit "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知操作: $action"
            ;;
    esac
}

main "$@"
