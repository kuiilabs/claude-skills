#!/bin/bash

# Ollama 模型极速下载 - aria2 多线程版
# 使用 aria2c 16 线程并发下载，速度提升 5-10 倍

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "用法：$0 <model-name>"
    echo "示例：$0 gemma4:31b"
    exit 1
fi

MODEL="$1"
TEMP_DIR="/tmp/ollama-$$"
REGISTRY="https://registry.ollama.ai"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "============================================================"
log_info "  Ollama 极速下载 (aria2c 16 线程)"
log_info "============================================================"
log_info "模型：$MODEL"
log_info ""

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 解析模型名称（处理 tag 格式，如 gemma4:31b）
MODEL_NAME="${MODEL%%:*}"
MODEL_TAG="${MODEL##*:}"
if [ "$MODEL_NAME" = "$MODEL_TAG" ]; then
    MODEL_TAG="latest"
fi

log_info "获取模型 manifest..."
# 获取模型 digest
DIGEST=$(curl -s "${REGISTRY}/v2/library/${MODEL_NAME}/manifests/${MODEL_TAG}" | \
    jq -r '.layers[] | select(.mediaType == "application/vnd.ollama.image.model") | .digest')

if [ -z "$DIGEST" ] || [ "$DIGEST" = "null" ]; then
    log_error "无法获取模型信息，请检查模型名称：$MODEL"
    rm -rf "$TEMP_DIR"
    exit 1
fi

log_info "模型 Digest: ${DIGEST}"
log_info ""

# 构建下载 URL
DOWNLOAD_URL="${REGISTRY}/v2/library/${MODEL_NAME}/blobs/${DIGEST}"

log_info "开始下载 (16 线程并发)..."
log_info "URL: ${DOWNLOAD_URL}"
log_info ""

# 使用 aria2 下载
aria2c -x 16 -s 16 -k 5M \
    --max-connection-per-server=16 \
    --split=16 \
    --min-split-size=5M \
    --continue=true \
    --max-tries=5 \
    --retry-wait=2 \
    --connect-timeout=10 \
    --timeout=60 \
    -d "$TEMP_DIR" \
    -o "model.gguf" \
    "$DOWNLOAD_URL"

RESULT=$?

if [ $RESULT -eq 0 ]; then
    log_success ""
    log_success "下载完成！导入到 Ollama..."

    # 创建 Modelfile
    echo "FROM $TEMP_DIR/model.gguf" > "$TEMP_DIR/Modelfile"

    # 创建模型
    ollama create "$MODEL" -f "$TEMP_DIR/Modelfile"

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
