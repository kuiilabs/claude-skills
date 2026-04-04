---
name: video-transcript
version: "1.0.0"
description: 提取视频字幕/转录文本，输出 Obsidian 兼容的 Markdown 格式。支持 YouTube、Bilibili 等平台。当用户提供视频链接时自动触发，生成可直接在 Obsidian 中阅读的笔记。
author: kuiilabs
tags: ["video", "transcript", "youtube", "bilibili", "obsidian"]
license: "MIT"
---

# Video Transcript - 视频转录技能

将视频链接转换为文字稿，支持多语言翻译。

## 触发场景

当用户提供视频链接（YouTube、Bilibili 等）并要求：
- 提取字幕/文字稿
- 生成视频摘要
- 翻译视频内容
- 获取讲稿/逐字稿

## 支持的平台

| 平台 | 链接示例 |
|------|----------|
| YouTube | https://youtube.com/watch?v=xxx |
| Bilibili | https://bilibili.com/video/BVxxx |
| 其他 | 任何 yt-dlp 支持的平台 |

## 工作流程

### 1. 检查环境依赖

首先确认工具已安装：

```bash
# 检查 yt-dlp
yt-dlp --version

# 检查 ffmpeg（用于音频处理）
ffmpeg -version

# 检查 Python 3
python3 --version
```

### 2. 提取字幕

```bash
# 下载字幕（如果有内嵌字幕）
yt-dlp --write-sub --sub-lang en --skip-download "<视频链接>"

# 下载双语字幕
yt-dlp --write-sub --sub-lang en,zh-CN --skip-download "<视频链接>"
```

### 3. 导出为 Obsidian Markdown

```bash
# 使用导出脚本
python3 ~/.claude/skills/video-transcript/scripts/export_obsidian.py \
    "<视频链接>" \
    "video.en.vtt" \
    "video.zh-CN.vtt" \
    "/Users/kui/Documents/Obsidian Vault/claude code/"
```

默认保存位置：`/Users/kui/Documents/Obsidian Vault/claude code/`

### 4. 在 Obsidian 中打开

生成的 Markdown 文件包含：
- YAML Frontmatter（元数据）
- 双语对照表格
- 关键要点区域（待填写）
- 双向链接区域

## 输出格式（Obsidian 兼容）

### 完整笔记格式

```markdown
---
tags: [video-transcript, 笔记]
created: YYYY-MM-DD
source: 视频链接
---

# 视频标题

## 📝 基本信息

- **来源**: 视频标题
- **链接**: <URL>
- **日期**: YYYY-MM-DD
- **时长**: XX:XX

## 📋 文字稿对照

| 时间 | 英文原文 | 中文翻译 |
|------|---------|---------|
| 00:00 | ... | ... |

## 💡 关键要点

- 要点 1
- 要点 2

## 🔗 相关链接

- [[相关笔记 1]]
- [[相关笔记 2]]
```

### 特性说明

1. **YAML Frontmatter**: Obsidian 元数据，支持标签、日期等
2. **双向链接**: 使用 `[[链接]]` 格式
3. **Callout**: 使用 `> [!INFO]` 格式的高亮框
4. **表格**: 时间戳对照表

## 注意事项

1. **版权**: 仅用于个人学习/研究
2. **准确性**: 自动转录可能有误差，需人工校对
3. **语言检测**: 先检测原语言，再决定是否翻译

## 相关命令

```bash
# 列出可用字幕
yt-dlp --list-subs "<视频链接>"

# 下载双语字幕
yt-dlp --write-sub --sub-lang en,zh --skip-download "<视频链接>"

# 提取音频
yt-dlp -x --audio-format mp3 "<视频链接>"

# 导出为 Obsidian Markdown
python3 ~/.claude/skills/video-transcript/scripts/export_obsidian.py \
    "<视频链接>" \
    "video.en.vtt" \
    "video.zh-CN.vtt" \
    "/Users/kui/Documents/Obsidian Vault/claude code/"
```

## Obsidian 使用提示

1. **双链**: 在 `[[相关链接]]` 区域添加内部链接
2. **标签**: 使用 `#video-transcript` 查找所有视频笔记
3. **模板**: 复制生成的文件作为新视频笔记模板
4. **Dataview**: 利用 YAML Frontmatter 创建视频笔记索引
