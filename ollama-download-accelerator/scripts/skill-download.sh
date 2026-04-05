#!/bin/bash

# Ollama 模型极速下载 - Skill 主脚本
# 支持代理自动检测和多线程加速

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 默认配置
MODEL=""
PROXY="${OLLAMA_PROXY:-}"  # 支持从环境变量读取代理
REGISTRY="https://registry.ollama.ai"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --proxy)
            PROXY="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        *)
            if [ -z "$MODEL" ]; then
                MODEL="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$MODEL" ]; then
    log_error "请提供模型名称，例如：gemma4:31b"
    exit 1
fi

log_info "============================================================"
log_info "  Ollama 极速下载 (Skill 模式)"
log_info "============================================================"
log_info "模型：$MODEL"
log_info "代理：${PROXY:-未使用}"
log_info ""

# 创建临时目录
TEMP_DIR="/tmp/ollama-skill-download-$$"
mkdir -p "$TEMP_DIR"

# 解析模型名称
MODEL_NAME="${MODEL%%:*}"
MODEL_TAG="${MODEL##*:}"
if [ "$MODEL_NAME" = "$MODEL_TAG" ]; then
    MODEL_TAG="latest"
fi

log_info "获取模型信息..."

# 获取模型 digest
DIGEST=$(curl -s "${REGISTRY}/v2/library/${MODEL_NAME}/manifests/${MODEL_TAG}" | \
    jq -r '.layers[] | select(.mediaType == "application/vnd.ollama.image.model") | .digest' 2>/dev/null) || {
    log_error "无法获取模型信息，请检查模型名称"
    exit 1
}

if [ -z "$DIGEST" ]; then
    log_error "无法获取模型 digest"
    exit 1
fi

log_info "模型 Digest: ${DIGEST}"
log_info ""

# 构建下载 URL
DOWNLOAD_URL="${REGISTRY}/v2/library/${MODEL_NAME}/blobs/${DIGEST}"

# 开始下载
if [ -n "$PROXY" ]; then
    log_info "使用代理加速下载..."
    log_info "代理：$PROXY"
    aria2c -x 16 -s 16 -k 10M \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=10M \
        --continue=true \
        --all-proxy="$PROXY" \
        --max-tries=10 \
        --retry-wait=1 \
        --connect-timeout=15 \
        --timeout=120 \
        --disk-cache=64M \
        -d "$TEMP_DIR" \
        -o "model.gguf" \
        "$DOWNLOAD_URL"
else
    log_info "使用 aria2 多线程下载..."
    aria2c -x 16 -s 16 -k 10M \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=10M \
        --continue=true \
        --max-tries=10 \
        --retry-wait=1 \
        --connect-timeout=15 \
        --timeout=120 \
        --disk-cache=64M \
        -d "$TEMP_DIR" \
        -o "model.gguf" \
        "$DOWNLOAD_URL"
fi

if [ $? -eq 0 ]; then
    log_success ""
    log_success "下载完成！导入到 Ollama..."

    # 创建 Modelfile
    echo "FROM $TEMP_DIR/model.gguf" > "$TEMP_DIR/Modelfile"

    # 创建模型
    ollama create "$MODEL" -f "$TEMP_DIR/Modelfile" 2>/dev/null || true

    # 清理
    rm -rf "$TEMP_DIR"

    log_success ""
    log_success "============================================================"
    log_success "  ✅ 模型 $MODEL 已就绪！"
    log_success "============================================================"
    ollama list | grep "$MODEL"
else
    log_error "下载失败"
    rm -rf "$TEMP_DIR"
    exit 1
fi