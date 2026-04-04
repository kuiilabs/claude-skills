---
name: github-sync-skill
version: "1.0.0"
description: 将本地创建或修改的 Claude Code 技能自动同步到 GitHub 仓库。支持初次发布和增量更新，自动检测变更并生成提交信息。
author: kuiilabs
tags: ["github", "sync", "backup", "automation", "git", "skill-management"]
license: "MIT"
---

# GitHub Sync Skill - 技能同步工具

将本地技能自动同步到 GitHub 仓库的辅助工具。

## 触发场景

当用户要求：
- 把技能同步到 GitHub
- 发布技能到 GitHub
- 备份我的技能
- 更新 GitHub 上的技能仓库
- "sync my skills to GitHub"

## 核心功能

### 1. 初次发布
- 初始化 Git 仓库
- 创建 GitHub 仓库（可选）
- 配置用户信息
- 提交并推送所有技能

### 2. 增量同步
- 检测变更文件
- 生成提交信息
- 自动推送更新

### 3. Token 权限验证
- 检查 Token 有效性
- 验证 repo 权限
- 提供修复建议

## 工作流程

### 1. 检查环境

```bash
# 检查 Git
git --version

# 检查 GitHub CLI（可选）
gh --version

# 检查 Token 环境变量
echo $GITHUB_TOKEN
```

### 2. 验证 Token 权限

```bash
# 验证 Token 所有者
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user | jq -r '.login'

# 验证仓库权限
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/<owner>/<repo> | jq '.permissions'
```

### 3. 执行同步

```bash
# 运行同步脚本
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh \
  --owner kuiilabs \
  --repo claude-skills \
  --token $GITHUB_TOKEN
```

## 输出格式

### 同步报告

```markdown
## GitHub Sync Report

**仓库**: kuiilabs/claude-skills
**时间**: 2026-04-04 23:45:00
**状态**: ✅ 成功

### 变更文件
- ✅ ip-risk-scanner/SKILL.md (updated)
- ✅ video-transcript/SKILL.md (new)

### 提交信息
Add 2 skills: ip-risk-scanner, video-transcript

### 仓库链接
https://github.com/kuiilabs/claude-skills
```

## 注意事项

1. **Token 安全**: 不要将 Token 提交到代码仓库
2. **权限要求**: Token 需要 `repo` scope
3. **网络环境**: 需要能访问 GitHub API
4. **冲突处理**: 如有冲突需手动解决

## 相关命令

```bash
# 完整同步
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh

# 仅检查变更
~/.claude/skills/github-sync-skill/scripts/check_changes.sh

# 验证 Token
~/.claude/skills/github-sync-skill/scripts/verify_token.sh

# 创建 GitHub 仓库
~/.claude/skills/github-sync-skill/scripts/create_repo.sh
```

## 安全最佳实践

1. **Token 存储**: 使用环境变量或密钥管理工具
2. **Token 过期**: 设置提醒定期更新（建议 30-90 天）
3. **权限最小化**: 仅授予必要权限
4. **审计日志**: 定期检查 GitHub 登录活动

## 故障排查

| 问题 | 错误信息 | 解决方案 |
|------|---------|---------|
| Token 过期 | `401 Bad credentials` | 重新生成 Token |
| 权限不足 | `403 Resource not accessible` | 添加 `repo` scope |
| 仓库不存在 | `404 Not Found` | 先创建仓库 |
| 网络超时 | `Connection timeout` | 检查网络/代理设置 |
