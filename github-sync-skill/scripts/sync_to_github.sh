#!/bin/bash

# GitHub Sync Script - 技能同步到 GitHub
# 用法：sync_to_github.sh [--owner owner] [--repo repo] [--token token] [--mode all|user]

set -e

# 默认配置
DEFAULT_OWNER="kuiilabs"
DEFAULT_REPO="claude-skills"
SKILLS_DIR="$HOME/.claude/skills"
GIT_USER_NAME="kuiilabs"
GIT_USER_EMAIL="kuiilabs@users.noreply.github.com"

# 用户创建的技能列表（通过文件修改时间判断）
USER_CREATED_SKILLS=(
    "ip-risk-scanner"
    "video-transcript"
    "github-sync-skill"
)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 解析参数
OWNER="$DEFAULT_OWNER"
REPO="$DEFAULT_REPO"
TOKEN="$GITHUB_TOKEN"
SYNC_MODE="user"  # 默认只同步用户创建的技能

while [[ $# -gt 0 ]]; do
    case $1 in
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --repo)
            REPO="$2"
            shift 2
            ;;
        --token)
            TOKEN="$2"
            shift 2
            ;;
        --mode)
            SYNC_MODE="$2"
            shift 2
            ;;
        --help)
            echo "用法：$0 [--owner owner] [--repo repo] [--token token] [--mode all|user]"
            echo ""
            echo "选项:"
            echo "  --owner    GitHub 用户名或组织 (默认：$DEFAULT_OWNER)"
            echo "  --repo     仓库名称 (默认：$DEFAULT_REPO)"
            echo "  --token    GitHub PAT Token (或使用 GITHUB_TOKEN 环境变量)"
            echo "  --mode     同步模式：user(仅用户创建) | all(全部) (默认：user)"
            echo ""
            echo "示例:"
            echo "  # 仅同步用户创建的技能"
            echo "  $0 --owner kuiilabs --repo claude-skills --token ghp_xxx"
            echo ""
            echo "  # 同步所有技能"
            echo "  $0 --mode all --owner kuiilabs --repo claude-skills --token ghp_xxx"
            exit 0
            ;;
        *)
            echo "未知选项：$1"
            exit 1
            ;;
    esac
done

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查环境依赖..."

    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        log_error "curl 未安装，请先安装 curl"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        log_warning "jq 未安装，建议安装以获得更好的体验"
    fi

    log_success "环境检查完成"
}

# 验证 Token
verify_token() {
    log_info "验证 GitHub Token..."

    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，请使用 --token 参数或设置 GITHUB_TOKEN 环境变量"
        exit 1
    fi

    # 验证 Token 所有者
    response=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user)

    if echo "$response" | grep -q '"login"'; then
        login=$(echo "$response" | jq -r '.login' 2>/dev/null || echo "unknown")
        log_success "Token 有效，所有者：$login"
    else
        log_error "Token 无效，请检查 Token 是否正确"
        echo "响应：$response"
        exit 1
    fi
}

# 检查仓库是否存在
check_repo_exists() {
    log_info "检查仓库是否存在..."

    response=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$OWNER/$REPO")

    if echo "$response" | grep -q '"full_name"'; then
        log_success "仓库已存在：$OWNER/$REPO"
        return 0
    else
        log_warning "仓库不存在，将创建新仓库"
        return 1
    fi
}

# 创建仓库
create_repo() {
    log_info "创建仓库 $OWNER/$REPO..."

    response=$(curl -s -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO\",\"private\":false,\"auto_init\":true}")

    if echo "$response" | grep -q '"full_name"'; then
        log_success "仓库创建成功：$OWNER/$REPO"
        return 0
    else
        log_error "仓库创建失败"
        echo "响应：$response"
        exit 1
    fi
}

# 初始化 Git 仓库
init_git() {
    log_info "初始化 Git 仓库..."

    cd "$SKILLS_DIR"

    if [ ! -d ".git" ]; then
        git init
        log_success "Git 仓库初始化完成"
    else
        log_info "Git 仓库已存在"
    fi

    # 配置用户信息
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    log_success "Git 用户配置完成"
}

# 添加远程仓库
add_remote() {
    log_info "配置远程仓库..."

    cd "$SKILLS_DIR"

    # 移除已存在的 origin
    git remote remove origin 2>/dev/null || true

    # 添加新的 origin（带 Token）
    git remote add origin "https://$OWNER:$TOKEN@github.com/$OWNER/$REPO.git"
    log_success "远程仓库配置完成"
}

# 获取要同步的技能列表
get_skills_to_sync() {
    if [ "$SYNC_MODE" == "user" ]; then
        log_info "同步模式：仅用户创建的技能"
        log_info "用户创建的技能列表："
        for skill in "${USER_CREATED_SKILLS[@]}"; do
            echo "   - $skill"
        done
        echo ""
    else
        log_info "同步模式：所有技能"
    fi
}

# 只添加指定技能目录的文件
add_user_skills() {
    cd "$SKILLS_DIR"

    if [ "$SYNC_MODE" == "user" ]; then
        log_info "添加用户创建的技能文件..."

        # 先重置暂存区
        git reset HEAD . 2>/dev/null || true

        # 只添加用户创建的技能
        for skill in "${USER_CREATED_SKILLS[@]}"; do
            if [ -d "$skill" ]; then
                git add "$skill/"
                log_info "  ✅ 添加：$skill/"
            else
                log_warning "  ⚠️  技能目录不存在：$skill"
            fi
        done

        # 添加 SKILL.md 如果存在
        if [ -f "SKILL.md" ]; then
            git add "SKILL.md"
        fi
    else
        # 同步所有技能
        git add .
    fi
}

# 检测变更
detect_changes() {
    log_info "检测文件变更..."

    cd "$SKILLS_DIR"

    # 获取变更统计
    changed=$(git status --porcelain | wc -l | tr -d ' ')

    if [ "$changed" -eq 0 ]; then
        log_info "没有检测到变更"
        return 1
    else
        log_success "检测到 $changed 个文件变更"
        return 0
    fi
}

# 提交变更
commit_changes() {
    log_info "提交变更..."

    cd "$SKILLS_DIR"

    # 获取变更的技能列表
    skills=$(git status --porcelain | grep -oE '(ip-risk-scanner|video-transcript|github-sync-skill)' | sort -u | tr '\n' ', ' | sed 's/,$//' || echo "skills")

    # 生成提交信息
    if [ -n "$skills" ]; then
        commit_msg="Sync skills: $skills"
    else
        commit_msg="Update skills"
    fi

    # 添加文件
    add_user_skills

    # 检查是否有变更
    if ! detect_changes; then
        log_info "无需提交"
        return 0
    fi

    git commit -m "$commit_msg"
    log_success "提交完成：$commit_msg"
}

# 推送变更
push_changes() {
    log_info "推送到 GitHub..."

    cd "$SKILLS_DIR"

    # 确保分支名为 main
    git branch -M main 2>/dev/null || true

    # 推送
    git push -u origin main

    log_success "推送成功"
}

# 生成报告
generate_report() {
    log_info "生成同步报告..."

    echo ""
    echo "============================================================"
    echo "  GitHub Sync Report"
    echo "============================================================"
    echo ""
    echo "仓库：$OWNER/$REPO"
    echo "时间：$(date '+%Y-%m-%d %H:%M:%S')"
    echo "同步模式：$SYNC_MODE"
    if [ "$SYNC_MODE" == "user" ]; then
        echo "同步的技能：${USER_CREATED_SKILLS[*]}"
    fi
    echo "状态：✅ 成功"
    echo ""
    echo "仓库链接：https://github.com/$OWNER/$REPO"
    echo ""
    echo "============================================================"
}

# 主流程
main() {
    echo ""
    echo "============================================================"
    echo "  GitHub Sync - 技能同步工具"
    echo "============================================================"
    echo ""

    get_skills_to_sync

    check_dependencies
    verify_token

    # 检查仓库是否存在，不存在则创建
    if ! check_repo_exists; then
        create_repo
    fi

    init_git
    add_remote
    commit_changes
    push_changes

    generate_report
}

# 执行主流程
main
