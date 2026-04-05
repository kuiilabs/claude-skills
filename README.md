# Claude Code Skills Collection

> 个人原创 Claude Code 技能集合

## 📚 技能列表

### github-sync-skill

将本地创建或修改的 Claude Code 技能自动同步到 GitHub 仓库。支持增量同步、单技能同步、自动生成 README.md。

**标签**: github,,sync,,backup,,automation,,git,,skill-management

### ip-risk-scanner

IP 安全评估工具。当用户提供 IP 地址时自动触发，输出详细的 IP 安全评分报告（0-100 分，越高越安全）。基于 Claude 官方 IP 审查机制，自动保存≥80 分的安全 IP 报告到 Obsidian。

**标签**: security,,ip-scan,,claude-code,,safety,,network

### ollama-download-accelerator

加速 Ollama 模型下载的工具。支持多镜像源（阿里云、腾讯云）、HTTP 代理、自定义 Ollama 服务地址。

**标签**: ollama,,download,,accelerator,,mirror,,ai-model

### video-transcript

提取视频字幕/转录文本，输出 Obsidian 兼容的 Markdown 格式。支持 YouTube、Bilibili 等平台。当用户提供视频链接时自动触发，生成可直接在 Obsidian 中阅读的笔记。

**标签**: video,,transcript,,youtube,,bilibili,,obsidian

## 🚀 使用方法

### 安装

1. 克隆本仓库：
```bash
git clone https://github.com/kuiilabs/claude-skills.git
```

2. 将技能链接到 Claude Code 目录：
```bash
ln -s $(pwd)/<skill-name> ~/.claude/skills/<skill-name>
```

### 同步新技能

使用 `github-sync-skill` 自动同步：

```bash
# 增量同步所有用户技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh

# 仅同步指定技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh --skill <skill-name>
```

## 📝 更新日志

* 2026-04-05 - 清理仓库，只保留原创技能