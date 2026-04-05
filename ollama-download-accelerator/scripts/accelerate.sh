#!/bin/bash

# Ollama 下载加速脚本
# 用法：accelerate.sh <model-name> [mirror]

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

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

# 默认配置
MODEL=""
MIRROR="aliyun"  # 默认使用阿里云镜像
PROXY=""
OLLAMA_HOST=""

# 镜像源配置（兼容 zsh）
get_mirror_url() {
    case "$1" in
        aliyun)
            echo "https://ollama.registry.aliyuncs.com"
            ;;
        tencent)
            echo "https://mirror.ccs.tencentyun.com/ollama"
            ;;
        official)
            echo "https://ollama.com"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --mirror)
            MIRROR="$2"
            shift 2
            ;;
        --proxy)
            PROXY="$2"
            shift 2
            ;;
        --host)
            OLLAMA_HOST="$2"
            shift 2
            ;;
        --help)
            echo "用法：$0 <model-name> [options]"
            echo ""
            echo "选项:"
            echo "  --mirror    镜像源 (aliyun|tencent|official, 默认：aliyun)"
            echo "  --proxy     HTTP 代理地址 (如：http://127.0.0.1:7890)"
            echo "  --host      Ollama 服务地址 (默认：http://127.0.0.1:11434)"
            echo ""
            echo "示例:"
            echo "  $0 gemma4:31b"
            echo "  $0 gemma4:31b --mirror tencent"
            echo "  $0 gemma4:31b --proxy http://127.0.0.1:7890"
            exit 0
            ;;
        *)
            if [ -z "$MODEL" ]; then
                MODEL="$1"
            fi
            shift
            ;;
    esac
done

# 检查模型名称
if [ -z "$MODEL" ]; then
    log_error "请提供模型名称，例如：gemma4:31b"
    echo "使用 --help 查看帮助"
    exit 1
fi

# 检查 ollama 是否安装
if ! command -v ollama &> /dev/null; then
    log_error "ollama 未安装，请先安装 ollama"
    exit 1
fi

# 设置代理
if [ -n "$PROXY" ]; then
    log_info "使用代理：$PROXY"
    export HTTP_PROXY="$PROXY"
    export HTTPS_PROXY="$PROXY"
fi

# 设置镜像源
MIRROR_URL=$(get_mirror_url "$MIRROR")
if [ -n "$MIRROR_URL" ]; then
    log_info "使用镜像源：$MIRROR (${MIRROR_URL})"
    export OLLAMA_REGISTRY="${MIRROR_URL}"
else
    log_warning "未知的镜像源：$MIRROR，使用官方源"
    MIRROR_URL=$(get_mirror_url "official")
    export OLLAMA_REGISTRY="${MIRROR_URL}"
fi

# 设置 Ollama 服务地址
if [ -n "$OLLAMA_HOST" ]; then
    log_info "使用 Ollama 服务地址：$OLLAMA_HOST"
    export OLLAMA_HOST="$OLLAMA_HOST"
fi

# 显示下载信息
echo ""
echo "============================================================"
echo "  Ollama 下载加速器"
echo "============================================================"
echo ""
echo "模型：$MODEL"
echo "镜像源：$MIRROR"
echo "代理：${PROXY:-未使用}"
echo ""
echo "开始下载..."
echo ""

# 方法 1: 使用 ollama 自带命令（通过环境变量加速）
ollama pull "$MODEL"

RESULT=$?

echo ""
if [ $RESULT -eq 0 ]; then
    log_success "模型 $MODEL 下载完成！"
    echo ""

    # 显示模型信息
    echo "============================================================"
    echo "  模型信息"
    echo "============================================================"
    ollama show "$MODEL" 2>/dev/null || true
    echo ""
else
    log_error "下载失败，请检查网络连接或尝试其他镜像源"
    echo ""
    echo "建议："
    echo "  1. 尝试其他镜像源：--mirror tencent"
    echo "  2. 使用代理：--proxy http://127.0.0.1:7890"
    echo "  3. 检查 Ollama 服务：ollama serve"
fi

exit $RESULT
