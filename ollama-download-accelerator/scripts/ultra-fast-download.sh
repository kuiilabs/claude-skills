#!/bin/bash

# Ollama 模型极速下载工具 - aria2 多线程版
# 使用 aria2c 16 线程并发下载，速度提升 5-10 倍

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# 检查依赖
check_dependencies() {
    if ! command -v aria2c &> /dev/null; then
        log_error "aria2c 未安装，请先安装：brew install aria2"
        exit 1
    fi
    if ! command -v ollama &> /dev/null; then
        log_error "ollama 未安装，请先安装：brew install ollama"
        exit 1
    fi
}

# 获取模型 manifest
get_model_manifest() {
    local model=$1
    log_info "获取模型清单：$model"

    # 使用阿里云镜像获取 manifest
    local registry="https://ollama.registry.aliyuncs.com"
    local manifest_url="${registry}/v2/library/${model/://\/}/manifests/latest"

    curl -s "$manifest_url" | jq -r '.layers[] | select(.mediaType == "application/vnd.ollama.image.model") | .digest'
}

# 下载模型层
download_model_layer() {
    local digest=$1
    local output_dir=$2
    local registry="https://ollama.registry.aliyuncs.com"
    local download_url="${registry}/v2/library/gemma4/blobs/${digest}"
    local output_file="${output_dir}/$(echo $digest | cut -d: -f2)"

    log_info "使用 aria2c 16 线程下载..."

    aria2c -x 16 -s 16 -k 1M \
        --max-connection-per-server=16 \
        --min-split-size=1M \
        --split=16 \
        --max-file-not-found=5 \
        --retry-wait=2 \
        --connect-timeout=10 \
        --timeout=30 \
        --continue=true \
        -d "$output_dir" \
        -o "$(basename $output_file)" \
        "$download_url"
}

# 主函数
main() {
    if [ -z "$1" ]; then
        log_error "请提供模型名称，例如：$0 gemma4:31b"
        exit 1
    fi

    local model=$1
    log_info "=========================================================="
    log_info "  Ollama 极速下载 (aria2c 16 线程)"
    log_info "=========================================================="
    log_info "模型：$model"
    log_info ""

    check_dependencies

    # 创建临时目录
    local temp_dir="/tmp/ollama-download-$$"
    mkdir -p "$temp_dir"

    # 获取模型信息
    log_info "正在获取模型信息..."
    local digest=$(get_model_manifest "$model")

    if [ -z "$digest" ]; then
        log_error "无法获取模型清单，请检查模型名称"
        rm -rf "$temp_dir"
        exit 1
    fi

    log_info "模型 Digest: $digest"
    log_info ""

    # 下载模型
    download_model_layer "$digest" "$temp_dir"

    # 导入到 Ollama
    log_info "导入模型到 Ollama..."
    local model_file="${temp_dir}/$(echo $digest | cut -d: -f2)"

    # 使用 ollama import (如果支持) 或创建 Modelfile
    if command -v ollama import &> /dev/null; then
        ollama import "$model" "$model_file"
    else
        # 创建临时 Modelfile
        local modelfile="/tmp/Modelfile-$$"
        echo "FROM $model_file" > "$modelfile"
        ollama create "$model" -f "$modelfile"
        rm -f "$modelfile"
    fi

    # 清理临时文件
    rm -rf "$temp_dir"

    log_success ""
    log_success "=========================================================="
    log_success "  模型 $model 下载完成！"
    log_success "=========================================================="

    ollama list | grep "$model"
}

main "$@"
