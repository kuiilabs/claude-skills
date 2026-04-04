#!/usr/bin/env python3
"""
export_obsidian.py - 导出 Obsidian 格式的视频笔记
用法：python export_obsidian.py <视频链接> <英文字幕文件> <中文字幕文件> [输出目录]
"""

import sys
import re
from datetime import datetime
from pathlib import Path

def parse_vtt(content):
    """解析 VTT 字幕"""
    lines = content.strip().split('\n')
    subtitles = {}
    current_entry = None

    for line in lines:
        # 跳过头部
        if line.startswith('WEBVTT') or line.startswith('Kind:') or line.startswith('Language:'):
            continue
        if '翻译人员' in line or '校对人员' in line:
            continue

        # 时间戳行
        timestamp_pattern = r'(\d{2}:\d{2}:\d{2}\.\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}\.\d{3})'
        match = re.match(timestamp_pattern, line)

        if match:
            start = match.group(1)[:8]  # 去掉毫秒：00:00:12
            current_entry = start
            subtitles[start] = {'start': start, 'text': ''}
        elif current_entry and line.strip():
            subtitles[current_entry]['text'] += line.strip() + ' '

    return subtitles

def format_time(t):
    """简化时间格式"""
    return t[3:8]  # 去掉小时

def extract_video_id(url):
    """从 URL 提取视频 ID"""
    patterns = [
        r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)',
        r'bilibili\.com/video/(BV[a-zA-Z0-9]+)',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return 'unknown'

def generate_filename(video_title):
    """生成安全的文件名"""
    # 移除非法字符
    safe_title = re.sub(r'[<>:"/\\|？*]', '_', video_title)
    safe_title = safe_title[:50]  # 限制长度
    return safe_title

def main():
    if len(sys.argv) < 4:
        print("用法：python export_obsidian.py <视频链接> <英文字幕文件> <中文字幕文件> [输出目录]")
        print("示例：python export_obsidian.py https://youtu.be/xxx video.en.vtt video.zh-CN.vtt ./obsidian-notes")
        sys.exit(1)

    video_url = sys.argv[1]
    en_file = sys.argv[2]
    zh_file = sys.argv[3]
    output_dir = sys.argv[4] if len(sys.argv) > 4 else "."

    # 读取字幕
    with open(en_file, 'r', encoding='utf-8') as f:
        en_subs = parse_vtt(f.read())

    with open(zh_file, 'r', encoding='utf-8') as f:
        zh_subs = parse_vtt(f.read())

    # 生成标题
    video_id = extract_video_id(video_url)
    video_title = f"Video Transcript - {video_id}"

    # 创建输出目录
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    # 生成文件名
    filename = generate_filename(video_title)
    output_file = Path(output_dir) / f"{filename}.md"

    # 生成 Markdown
    md_content = generate_markdown(video_title, video_url, en_subs, zh_subs)

    # 写入文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"✅ Obsidian 笔记已生成：{output_file}")
    print(f"📁 文件大小：{output_file.stat().st_size} 字节")

def generate_markdown(title, url, en_subs, zh_subs):
    """生成 Obsidian 兼容的 Markdown"""

    now = datetime.now().strftime("%Y-%m-%d")

    md = []

    # YAML Frontmatter
    md.append("---")
    md.append(f"tags: [video-transcript, 笔记，视频]")
    md.append(f"created: {now}")
    md.append(f"source: {url}")
    md.append(f"aliases: []")
    md.append("---")
    md.append("")

    # 标题
    md.append(f"# 🎬 {title}")
    md.append("")

    # 基本信息
    md.append("## 📝 基本信息")
    md.append("")
    md.append(f"- **来源**: {title}")
    md.append(f"- **链接**: {url}")
    md.append(f"- **日期**: {now}")
    md.append(f"- **生成**: Obsidian video-transcript skill")
    md.append("")

    # 文字稿对照
    md.append("## 📋 文字稿对照")
    md.append("")
    md.append("| 时间 | 英文原文 | 中文翻译 |")
    md.append("|------|---------|---------|")

    # 合并字幕
    all_times = sorted(set(en_subs.keys()) | set(zh_subs.keys()))

    for t in all_times:
        time_fmt = format_time(t)
        en_text = en_subs.get(t, {}).get('text', '').strip()
        zh_text = zh_subs.get(t, {}).get('text', '').strip()

        # 清理文本
        en_text = ' '.join(en_text.split())
        zh_text = ' '.join(zh_text.split())

        # 转义 Markdown 特殊字符
        en_text = en_text.replace('|', '\\|')
        zh_text = zh_text.replace('|', '\\|')

        if en_text or zh_text:
            md.append(f"| {time_fmt} | {en_text} | {zh_text} |")

    md.append("")

    # 关键要点（留空让用户填充）
    md.append("## 💡 关键要点")
    md.append("")
    md.append("<!-- 在此添加你的笔记摘要 -->")
    md.append("")
    md.append("- ")
    md.append("")

    # 相关链接（Obsidian 双向链接）
    md.append("## 🔗 相关链接")
    md.append("")
    md.append("<!-- 在此添加相关笔记的双向链接 -->")
    md.append("")
    md.append("- [[笔记模板]]")
    md.append("")

    # Callout 示例
    md.append("> [!INFO] 提示")
    md.append("> 此文档由 video-transcript 技能自动生成")
    md.append("> 可以在 Obsidian 中使用 `Ctrl/Cmd+P` 搜索此文件")
    md.append("")

    return '\n'.join(md)

if __name__ == '__main__':
    main()
