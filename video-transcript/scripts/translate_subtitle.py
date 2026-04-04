#!/usr/bin/env python3
"""
translate_subtitle.py - 翻译字幕文件
用法：python translate_subtitle.py <字幕文件> [目标语言]
"""

import sys
import json
import re
from pathlib import Path

def parse_vtt(content: str) -> list:
    """解析 VTT 字幕格式"""
    lines = content.strip().split('\n')
    subtitles = []

    # 跳过 WEBVTT 头部
    start_idx = 0
    for i, line in enumerate(lines):
        if line.startswith('WEBVTT'):
            start_idx = i + 1
            break

    i = start_idx
    while i < len(lines):
        line = lines[i].strip()

        # 跳过空行
        if not line:
            i += 1
            continue

        # 尝试解析时间戳行 (如：00:00:01.000 --> 00:00:05.000)
        timestamp_pattern = r'(\d{2}:\d{2}:\d{2}\.\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}\.\d{3})'
        match = re.match(timestamp_pattern, line)

        if match:
            start_time = match.group(1)
            end_time = match.group(2)

            # 收集字幕文本（直到下一个空行）
            text_lines = []
            i += 1
            while i < len(lines) and lines[i].strip():
                text_lines.append(lines[i].strip())
                i += 1

            text = ' '.join(text_lines)
            subtitles.append({
                'start': start_time,
                'end': end_time,
                'text': text
            })
        else:
            i += 1

    return subtitles

def format_timestamp_for_claude(start: str, end: str) -> str:
    """简化时间戳格式"""
    # 将 00:00:01.000 转换为 00:01
    start_simple = start[3:-4]  # 去掉小时和毫秒
    end_simple = end[3:-4]
    return f"[{start_simple}-{end_simple}]"

def main():
    if len(sys.argv) < 2:
        print("用法：python translate_subtitle.py <字幕文件> [目标语言]")
        print("示例：python translate_subtitle.py video.en.vtt zh")
        sys.exit(1)

    subtitle_file = sys.argv[1]
    target_lang = sys.argv[2] if len(sys.argv) > 2 else 'zh'

    if not Path(subtitle_file).exists():
        print(f"错误：文件不存在：{subtitle_file}")
        sys.exit(1)

    # 读取字幕文件
    with open(subtitle_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 解析字幕
    subtitles = parse_vtt(content)

    if not subtitles:
        print("⚠️  未找到字幕内容")
        sys.exit(0)

    print(f"📝 找到 {len(subtitles)} 条字幕")
    print("")

    # 输出格式化的字幕
    print("## 视频文字稿")
    print("")

    for sub in subtitles:
        timestamp = format_timestamp_for_claude(sub['start'], sub['end'])
        print(f"{timestamp} {sub['text']}")

    print("")
    print("---")
    print(f"💡 提示：将以上内容发送给 Claude 并请求翻译成{target_lang}")

if __name__ == '__main__':
    main()
