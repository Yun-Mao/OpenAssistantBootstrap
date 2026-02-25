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

  merge [pr-number]             合并PR（不提供PR号则自动查找当前分支的PR）
                                示例: ./git-workflow.sh merge
                                示例: ./git-workflow.sh merge 2

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

  # 4. 在GitHub上进行Code Review

  # 5. 合并PR
  ./git-workflow.sh merge

  # 6. 同步和清理
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
    
    # 检查gh CLI是否安装
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) 未安装，请先安装: https://cli.github.com"
    fi
    
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" == "main" ]; then
        log_error "当前在main分支上，请切换到feature分支"
    fi
    
    log_info "当前分支: $current_branch"
    
    # 推送到远端
    log_info "推送代码到远端..."
    git push -u origin "$current_branch"
    
    log_success "✨ 代码已推送到远端"
    
    # 使用GitHub CLI自动创建PR
    log_info "正在自动创建Pull Request..."
    
    if gh pr create \
        --title "$pr_title" \
        --body "## 功能说明\n\n$pr_title\n\n## 提交规范\n\n遵循 Conventional Commits 规范" \
        --base main \
        --head "$current_branch" 2>/dev/null; then
        log_success "✨ Pull Request 已自动创建！"
        echo ""
        
        # 获取PR URL
        local pr_url=$(gh pr view "$current_branch" --json url --jq .url 2>/dev/null || echo "")
        if [ -n "$pr_url" ]; then
            echo -e "${CYAN}PR链接:${NC}"
            echo "$pr_url"
            echo ""
        fi
    else
        log_warn "自动创建PR失败，请手动创建"
        log_warn "PR链接: https://github.com/Yun-Mao/OpenAssistantBootstrap/pull/new/$current_branch"
        echo ""
    fi
    
    echo -e "${YELLOW}下一步:${NC}"
    echo "1. 在GitHub上进行Code Review"
    echo "2. 审核通过后运行: ./git-workflow.sh merge"
    echo "3. 合并后运行: ./git-workflow.sh finalize"
    echo ""
}

# ==================== 合并PR ====================
merge_pr() {
    local pr_number="$1"
    
    check_git_status
    
    # 检查gh CLI是否安装
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) 未安装，请先安装: https://cli.github.com"
    fi
    
    local current_branch=$(get_current_branch)
    
    # 如果没有提供PR号，尝试查找当前分支的PR
    if [ -z "$pr_number" ]; then
        log_info "查找当前分支的PR..."
        pr_number=$(gh pr view "$current_branch" --json number --jq .number 2>/dev/null || echo "")
        
        if [ -z "$pr_number" ]; then
            log_error "未找到当前分支的PR，请指定PR号: ./git-workflow.sh merge <PR-number>"
        fi
    fi
    
    log_info "准备合并 PR #$pr_number..."
    
    # 显示PR信息
    gh pr view "$pr_number" --json title,state,url --template '{{.title}} ({{.state}})
{{.url}}
' || log_error "无法获取PR信息"
    
    echo ""
    read -p "确认要合并这个PR吗? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "取消合并操作"
        exit 0
    fi
    
    # 合并PR
    log_info "正在合并PR..."
    if gh pr merge "$pr_number" --merge; then
        log_success "✨ PR #$pr_number 已成功合并！"
        echo ""
        echo -e "${CYAN}下一步:${NC}"
        echo "运行: ./git-workflow.sh finalize"
        echo ""
    else
        log_error "PR合并失败，请检查是否有冲突或其他问题"
    fi
}

# ==================== 合并后清理 ====================
finalize() {
    check_git_status
    
    local current_branch=$(get_current_branch)
    local feature_branch="$current_branch"
    
    log_info "开始清理工作..."
    
    # 切换到main
    log_info "切换到main分支..."
    git checkout main
    
    # 同步远端
    log_info "同步远端最新内容..."
    git fetch origin
    git pull origin main
    
    # 删除本地feature分支
    if [ "$feature_branch" != "main" ]; then
        log_info "删除本地feature分支: $feature_branch"
        git branch -d "$feature_branch" 2>/dev/null || git branch -D "$feature_branch"
        
        # 删除远端feature分支
        log_info "删除远端feature分支..."
        git push origin --delete "$feature_branch" 2>/dev/null || true
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
        merge)
            merge_pr "$@"
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
