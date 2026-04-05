#!/bin/bash

# Ollama Run 命令包装器
# 用法：run.sh <model-name>
# 自动调用加速脚本下载模型，然后运行

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACCELERATE_SCRIPT="${SCRIPT_DIR}/accelerate.sh"

if [ -z "$1" ]; then
    echo "用法：$0 <model-name>[:tag]"
    echo "示例：$0 gemma4:31b"
    echo "      $0 llama3.2"
    exit 1
fi

MODEL="$1"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  Ollama 加速运行${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "模型：$MODEL"
echo ""

# 调用加速脚本下载模型
"${ACCELERATE_SCRIPT}" "$MODEL"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}下载完成！正在启动模型...${NC}"
    echo ""
    # 运行模型
    ollama run "$MODEL"
else
    echo ""
    echo -e "\033[0;31m[ERROR] 下载失败，尝试直接运行本地已有模型...\033[0m"
    ollama run "$MODEL"
fi
