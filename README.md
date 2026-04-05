# Claude Code Skills Collection

> 🚀 个人创建和开发的 Claude Code 技能集合，提升 AI 辅助开发效率

![GitHub stars](https://img.shields.io/github/stars/kuiilabs/claude-skills?style=for-the-badge)
![License](https://img.shields.io/github/license/kuiilabs/claude-skills?style=for-the-badge)
![Last Updated](https://img.shields.io/github/last-commit/kuiilabs/claude-skills?style=for-the-badge)

---

## 📚 技能列表

| 技能 | 版本 | 描述 | 标签 |
|------|------|------|------|
| **[wechat-saver](#wechat-saver)** | 1.1.0 | 微信公众号文章抓取工具，支持图片下载、智能格式识别 | WeChat, Markdown, Obsidian |
| **[ip-risk-scanner](#ip-risk-scanner)** | 2.0.0 | IP 安全评估工具，自动扫描并保存安全 IP 报告 | Security, IP Scan |
| **[video-transcript](#video-transcript)** | 1.0.0 | 提取 YouTube/Bilibili 视频字幕，生成 Obsidian 笔记 | Video, Transcript |
| **[github-sync-skill](#github-sync-skill)** | 2.0.0 | 本地技能自动同步到 GitHub，支持增量更新 | GitHub, Sync |
| **[ollama-download-accelerator](#ollama-download-accelerator)** | 1.0.0 | 加速 Ollama 模型下载，支持多镜像源 | Ollama, Download |

---

## 🛠️ 技能详情

### wechat-saver

**版本**: 1.1.0 | **类别**: 内容工具

微信公众号文章抓取工具，专为 Obsidian 用户设计。

**核心功能**:
- ✅ 自动提取文章标题和正文
- ✅ 下载所有图片并使用 Obsidian 兼容的相对路径
- ✅ 智能格式识别：代码块、列表、引用自动格式化
- ✅ 添加 YAML Frontmatter 元数据
- ✅ 批量处理多篇文章

**使用方法**:
```bash
# 保存单篇文章
~/.claude/skills/wechat-saver/scripts/wechat_to_md.py https://mp.weixin.qq.com/s/xxx

# 指定输出目录
~/.claude/skills/wechat-saver/scripts/wechat_to_md.py -o ~/Obsidian/Articles <url>
```

---

### ip-risk-scanner

**版本**: 2.0.0 | **类别**: 安全工具

基于 Claude 官方 IP 审查机制的安全评估工具。

**核心功能**:
- 🔒 IP 安全评分（0-100 分）
- 📄 自动生成详细报告
- 💾 安全 IP（≥80 分）自动保存到 Obsidian
- 🌐 支持 IPv4/IPv6

**使用方法**:
```bash
# 扫描单个 IP
/scan-ip 192.168.1.1

# 扫描多个 IP
/scan-ip 192.168.1.1 10.0.0.1 172.16.0.1
```

---

### video-transcript

**版本**: 1.0.0 | **类别**: 内容工具

提取视频字幕，生成 Obsidian 兼容的 Markdown 笔记。

**支持平台**:
- YouTube
- Bilibili
- 其他支持字幕的视频平台

**使用方法**:
```bash
# 提供视频链接即可自动触发
https://www.youtube.com/watch?v=xxx
https://www.bilibili.com/video/BV1xx411c7mD
```

---

### github-sync-skill

**版本**: 2.0.0 | **类别**: 开发工具

将原创技能自动同步到 GitHub 仓库。

**核心功能**:
- 🔄 增量同步（只上传新技能）
- 📝 自动生成/更新 README.md
- 🔐 支持 Token 安全存储
- 🎯 支持单技能同步

**使用方法**:
```bash
# 同步所有新技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh --token <token>

# 同步指定技能
~/.claude/skills/github-sync-skill/scripts/sync_to_github.sh --skill wechat-saver --token <token>
```

---

### ollama-download-accelerator

**版本**: 1.0.0 | **类别**: 工具

加速 Ollama 模型下载，解决下载慢、连接超时问题。

**核心功能**:
- 🚀 多镜像源支持（阿里云、腾讯云）
- 🌐 HTTP 代理支持
- ⚙️ 自定义 Ollama 服务地址
- 📊 下载进度显示

**使用方法**:
```bash
# 下载模型（自动选择最快镜像）
ollama-download llama2

# 使用代理
ollama-download llama2 --proxy http://localhost:7890
```

---

## 📦 安装方法

### 1. 克隆本仓库

```bash
git clone https://github.com/kuiilabs/claude-skills.git
cd claude-skills
```

### 2. 链接技能到 Claude Code

```bash
# 示例：安装 wechat-saver
ln -s $(pwd)/wechat-saver ~/.claude/skills/wechat-saver

# 安装所有技能
for skill in */; do
  [ -d "$skill" ] && [ "$skill" != "./" ] && ln -s $(pwd)/${skill%/} ~/.claude/skills/${skill%/}
done
```

### 3. 安装依赖

部分技能需要额外的 Python 依赖：

```bash
# wechat-saver 依赖
pip install requests readability-lxml beautifulsoup4 lxml

# 或使用虚拟环境
cd wechat-saver
python3 -m venv .venv
source .venv/bin/activate
pip install requests readability-lxml beautifulsoup4 lxml
```

---

## 🔧 配置说明

### GitHub Token 安全存储

```bash
# 创建私密目录
mkdir -p ~/.claude/private
echo "<your-github-token>" > ~/.claude/private/github_token
chmod 600 ~/.claude/private/github_token

# 添加到全局 gitignore
echo ".claude/private" >> ~/.gitignore_global
```

---

## 📝 更新日志

| 日期 | 技能 | 版本 | 更新内容 |
|------|------|------|---------|
| 2026-04-05 | wechat-saver | 1.1.0 | 新增智能格式识别（代码块/列表/引用）、空行自动清理 |
| 2026-04-05 | wechat-saver | 1.0.0 | 初始版本：微信文章抓取、图片下载 |
| 2026-04-05 | github-sync-skill | 2.0.0 | 新增 Token 安全存储、README 自动生成 |
| 2026-04-05 | ip-risk-scanner | 2.0.0 | 支持 IPv6、报告格式优化 |

---

## 🤝 贡献

本仓库仅包含原创技能，第三方技能不同步。

如需添加新技能：
1. 在本地创建技能目录
2. 编写 `SKILL.md` 说明文档
3. 运行同步脚本上传

---

## 📄 许可证

MIT License © 2026 kuiilabs
