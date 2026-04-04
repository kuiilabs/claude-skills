# Claude Code Skills Collection

> 个人创建和开发的 Claude Code 技能集合

## 📚 技能列表

### github-sync-skill

将本地创建或修改的 Claude Code 技能自动同步到 GitHub 仓库。支持增量同步、单技能同步、自动生成 README.md。

**标签**: github,,sync,,backup,,automation,,git,,skill-management

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

* 2026-04-04 - 初始化仓库，包含 ip-risk-scanner video-transcript github-sync-skill