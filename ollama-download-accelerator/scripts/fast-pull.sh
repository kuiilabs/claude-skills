#!/bin/bash

# Ollama 模型极速下载 - 默认使用 aria2 多线程
# 自动检测并调用最快的下载方式

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

MODEL="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查是否有 aria2
if command -v aria2c &> /dev/null; then
    log_info "检测到 aria2，使用 16 线程极速下载..."
    # 调用 aria2 版本
    exec "$SCRIPT_DIR/aria2-download.sh" "$MODEL"
else
    log_info "未检测到 aria2，使用单线程下载..."
    # 降级到普通版本
    export OLLAMA_REGISTRY="https://ollama.registry.aliyuncs.com"
    ollama pull "$MODEL"
fi