---
name: ollama-download-accelerator
version: "1.0.0"
description: 加速 Ollama 模型下载的工具。支持多镜像源（阿里云、腾讯云）、HTTP 代理、自定义 Ollama 服务地址。
author: kui
tags: ["ollama", "download", "accelerator", "mirror", "ai-model"]
license: "MIT"
---

# Ollama Download Accelerator - 模型下载加速工具

加速 Ollama 模型下载的工具，解决官方源下载慢或不稳定的问题。

## 触发场景

当用户在 Claude Code 中输入以下命令时触发：
- `ollama run <model-name>` - 运行/下载模型
- `ollama pull <model-name>` - 拉取模型
- `ollama run gemma4:31b` - 具体模型示例

当用户要求：
- 加速 Ollama 模型下载
- ollama pull 太慢了
- 下载模型卡住了
- "accelerate ollama download"
- "download gemma4 faster"
- 推荐 Ollama 镜像源

## 核心功能

### 1. 多镜像源支持

| 镜像源 | 地址 | 适用地区 |
|--------|------|----------|
| 阿里云 | `ollama.registry.aliyuncs.com` | 中国大陆 |
| 腾讯云 | `mirror.ccs.tencentyun.com/ollama` | 中国大陆 |
| 官方源 | `ollama.com` | 全球 |

### 2. HTTP 代理支持

支持配置 HTTP/HTTPS 代理，适用于有代理服务器的环境。

### 3. 自定义 Ollama 服务地址

支持指定 Ollama 服务地址（默认：http://127.0.0.1:11434）。

## 使用方法

### 方式 1：使用 Skill（推荐 - 对话式）

当你在 Claude Code 对话中输入 `ollama run <model>` 时，我会自动调用这个 skill。

**代理配置**（可选）：
```bash
# 设置代理环境变量
export OLLAMA_PROXY="http://127.0.0.1:7897"

# 或者直接传入
ollama run gemma4:31b --proxy http://127.0.0.1:7897
```

**脚本位置**：
```bash
~/.claude/skills/ollama-download-accelerator/scripts/skill-download.sh
```

**使用方式**：
```bash
# 基本用法（自动检测代理）
~/.claude/skills/ollama-download-accelerator/scripts/skill-download.sh gemma4:31b

# 指定代理
~/.claude/skills/ollama-download-accelerator/scripts/skill-download.sh gemma4:31b --proxy http://127.0.0.1:7897
```

在 `~/.zshrc` 中添加了包装函数后，直接在终端或 Claude Code 中输入：

```bash
# 下载并运行模型（自动加速）
ollama run gemma4:31b

# 仅下载模型（自动加速）
ollama pull gemma4:31b
```

**工作原理**:
- 包装函数会拦截 `ollama run` 和 `ollama pull` 命令
- 自动调用加速脚本下载模型
- 下载完成后自动启动模型（run 命令）

### 方式 2：直接调用加速脚本

```bash
# 使用默认镜像源（阿里云）
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b
```

### 指定镜像源

```bash
# 使用腾讯云镜像
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b --mirror tencent

# 使用官方源
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b --mirror official
```

### 使用代理

```bash
# 通过代理下载
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b --proxy http://127.0.0.1:7890
```

### 组合使用

```bash
# 腾讯云镜像 + 代理
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b \
  --mirror tencent \
  --proxy http://127.0.0.1:7890

# 指定 Ollama 服务地址
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b \
  --host http://192.168.1.100:11434
```

### 查看帮助

```bash
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh --help
```

## 输出格式

### 成功输出

```
[INFO] 使用镜像源：aliyun (https://ollama.registry.aliyuncs.com)

============================================================
  Ollama 下载加速器
============================================================

模型：gemma4:31b
镜像源：aliyun
代理：未使用

开始下载...

[SUCCESS] 模型 gemma4:31b 下载完成！
```

### 错误输出

```
[ERROR] ollama 未安装，请先安装 ollama
```

## 环境变量

脚本会设置以下环境变量：

| 变量 | 说明 |
|------|------|
| `OLLAMA_REGISTRY` | 镜像源地址 |
| `HTTP_PROXY` | HTTP 代理地址 |
| `HTTPS_PROXY` | HTTPS 代理地址 |
| `OLLAMA_HOST` | Ollama 服务地址 |

## 快捷别名（可选）

为了方便使用，可以在 `~/.zshrc` 中添加：

```bash
alias ollama-acc='~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh'
```

然后可以这样使用：

```bash
ollama-acc gemma4:31b
ollama-acc gemma4:31b --mirror tencent
ollama-acc gemma4:31b --proxy http://127.0.0.1:7890
```

## 注意事项

1. **ollama 安装**: 确保已安装 ollama (`brew install ollama`)
2. **服务运行**: 确保 ollama serve 正在运行
3. **镜像源稳定性**: 不同镜像源的稳定性可能随时间变化
4. **代理配置**: 代理地址格式为 `http://host:port`

## 故障排查

| 问题 | 错误信息 | 解决方案 |
|------|---------|---------|
| ollama 未安装 | `ollama 未安装` | 运行 `brew install ollama` |
| 服务未启动 | 连接拒绝 | 运行 `ollama serve` |
| 镜像源超时 | 连接超时 | 尝试其他镜像源 `--mirror tencent` |
| 代理失败 | 代理连接错误 | 检查代理地址是否正确 |

## 相关命令

```bash
# 检查 ollama 是否安装
ollama --version

# 启动 ollama 服务
ollama serve

# 查看已下载的模型
ollama list

# 删除模型
ollama rm <model-name>

# 查看模型信息
ollama show <model-name>
```

## 示例场景

### 场景 1：首次下载大模型

```bash
# 下载 gemma4:31b（约 19GB），使用阿里云镜像
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b
```

### 场景 2：官方源下载失败

```bash
# 切换到腾讯云镜像
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b --mirror tencent
```

### 场景 3：有代理服务器

```bash
# 通过代理加速
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b \
  --proxy http://127.0.0.1:7890
```

### 场景 4：远程 Ollama 服务

```bash
# 连接到局域网内的 Ollama 服务
~/.claude/skills/ollama-download-accelerator/scripts/accelerate.sh gemma4:31b \
  --host http://192.168.1.100:11434
```

## 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-04-04 | 初始版本，支持多镜像源和代理 |
