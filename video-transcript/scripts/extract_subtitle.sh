#!/usr/bin/env bash
# extract_subtitle.sh - 提取视频字幕
# 用法：./extract_subtitle.sh <视频链接> [语言]

set -e

VIDEO_URL="$1"
LANGUAGE="${2:-auto}"  # 默认自动检测

if [ -z "$VIDEO_URL" ]; then
    echo "用法：$0 <视频链接> [语言]"
    echo "示例：$0 https://youtube.com/watch?v=xxx en"
    exit 1
fi

echo "📺 视频链接：$VIDEO_URL"
echo "🌐 目标语言：$LANGUAGE"

# 创建输出目录
OUTPUT_DIR="./video-transcript-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "📁 输出目录：$OUTPUT_DIR"
echo ""

# 检查 yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ 错误：yt-dlp 未安装"
    echo "请运行：brew install yt-dlp"
    exit 1
fi

# 列出可用字幕
echo "🔍 检查可用字幕..."
yt-dlp --list-subs "$VIDEO_URL" 2>/dev/null || true
echo ""

# 下载字幕
echo "📥 下载字幕..."
if [ "$LANGUAGE" = "auto" ]; then
    # 自动下载所有可用字幕
    yt-dlp --write-sub --write-auto-sub --skip-download \
        -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
        "$VIDEO_URL"
else
    # 下载指定语言字幕
    yt-dlp --write-sub --sub-lang "$LANGUAGE" --skip-download \
        -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
        "$VIDEO_URL"
fi

echo ""
echo "✅ 完成！字幕文件在：$OUTPUT_DIR"
echo ""
echo "📄 查看文件:"
ls -la "$OUTPUT_DIR"
