Generating README.md...
# Claude Code Skills Collection

> 个人创建和开发的 Claude Code 技能集合

## 📚 技能列表

### ip-risk-scanner

IP 安全评估工具。当用户提供 IP 地址时自动触发，输出详细的 IP 安全评分报告（0-100 分，越高越安全）。基于 Claude 官方 IP 审查机制，自动保存≥80 分的安全 IP 报告到 Obsidian。

**标签**: security,  ip-scan,  claude-code,  safety,  network

### video-transcript

提取视频字幕/转录文本，输出 Obsidian 兼容的 Markdown 格式。支持 YouTube、Bilibili 等平台。当用户提供视频链接时自动触发，生成可直接在 Obsidian 中阅读的笔记。

**标签**: video,  transcript,  youtube,  bilibili,  obsidian

### github-sync-skill

将本地创建或修改的 Claude Code 技能自动同步到 GitHub 仓库。支持初次发布和增量更新，自动检测变更并生成提交信息。

**标签**: github,  sync,  backup,  automation,  git,  skill-management

## 🚀 使用方法

### 安装技能

1. 克隆本仓库：
```bash
git clone https://github.com/kuiilabs/claude-skills.git
```

2. 将技能链接到 Claude Code 目录：
```bash
cd claude-skills
ln -s $(pwd)/ip-risk-scanner ~/.claude/skills/ip-risk-scanner
ln -s $(pwd)/video-transcript ~/.claude/skills/video-transcript
ln -s $(pwd)/github-sync-skill ~/.claude/skills/github-sync-skill
```

### 同步技能

使用 `github-sync-skill` 自动同步：

```bash
# 增量同步所有用户技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh

# 仅同步指定技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh --skill <skill-name>
```

## 📦 技能详情

每个技能文件夹包含：
- `SKILL.md` - 技能说明文档
- `scripts/` - 执行脚本
- `references/` - 参考文档（可选）

## 📝 更新日志

* 2026-04-04 - 初始化仓库，包含 ip-risk-scanner, video-transcript, github-sync-skill
