# Clawdbot 使用指南

> 🦞 Clawdbot — 个人 AI 助手，通过聊天应用自动化你的日常任务

## 简介

Clawdbot 是一个开源的个人 AI 助手，可以通过 WhatsApp、Telegram、Discord 等聊天应用执行各种自动化任务，包括：

- 📧 管理邮件和收件箱
- 📅 日历管理和提醒
- ✈️ 航班自动值机
- 🔍 网页搜索和浏览
- 📁 文件操作
- ⏰ 定时任务和 Cron 调度

## 安装

```bash
curl -fsSL https://clawd.bot/install.sh | bash
```

安装完成后运行初始设置：

```bash
clawdbot setup
```

## 快速开始

### 1. 完整配置向导

```bash
clawdbot onboard
```

交互式向导会帮你设置网关、工作区和技能。

### 2. 配置凭证和设备

```bash
clawdbot configure
```

### 3. 启动网关服务

```bash
clawdbot gateway
```

或指定端口：

```bash
clawdbot gateway --port 18789
```

### 4. 开发模式

使用隔离的状态和配置：

```bash
clawdbot --dev gateway
```

## 核心命令

### 基础操作

| 命令 | 说明 |
|------|------|
| `clawdbot setup` | 初始化配置文件和工作区 |
| `clawdbot onboard` | 交互式配置向导 |
| `clawdbot configure` | 配置凭证、设备和代理 |
| `clawdbot config` | 配置助手（get/set/unset） |
| `clawdbot doctor` | 健康检查 + 快速修复 |
| `clawdbot dashboard` | 打开控制面板 UI |

### 网关和服务

| 命令 | 说明 |
|------|------|
| `clawdbot gateway` | 启动 WebSocket 网关 |
| `clawdbot gateway --force` | 强制启动（自动释放端口） |
| `clawdbot logs` | 查看网关日志 |
| `clawdbot status` | 查看渠道健康状态 |
| `clawdbot health` | 获取运行中网关的健康信息 |

### 消息和渠道

| 命令 | 说明 |
|------|------|
| `clawdbot channels` | 渠道管理 |
| `clawdbot channels login` | 登录渠道（WhatsApp/Telegram 等） |
| `clawdbot message send` | 发送消息 |
| `clawdbot agent` | 与 AI 代理对话 |

### 代理和会话

| 命令 | 说明 |
|------|------|
| `clawdbot agent` | 运行代理（通过网关或本地） |
| `clawdbot agents` | 管理隔离代理 |
| `clawdbot sessions` | 列出会话记录 |
| `clawdbot memory` | 内存搜索工具 |

### 系统工具

| 命令 | 说明 |
|------|------|
| `clawdbot tui` | 终端用户界面 |
| `clawdbot cron` | Cron 定时任务调度 |
| `clawdbot plugins` | 插件管理 |
| `clawdbot skills` | 技能管理 |
| `clawdbot browser` | 管理专用浏览器 |
| `clawdbot sandbox` | 沙箱工具 |

### 安全和设备

| 命令 | 说明 |
|------|------|
| `clawdbot devices` | 设备配对和令牌管理 |
| `clawdbot security` | 安全助手 |
| `clawdbot approvals` | 执行审批管理 |
| `clawdbot pairing` | 配对助手 |

### 其他

| 命令 | 说明 |
|------|------|
| `clawdbot update` | CLI 更新 |
| `clawdbot reset` | 重置本地配置/状态 |
| `clawdbot uninstall` | 卸载网关服务和本地数据 |
| `clawdbot docs` | 文档助手 |
| `clawdbot dns` | DNS 助手 |
| `clawdbot webhooks` | Webhook 助手 |

## 使用示例

### 连接 WhatsApp

```bash
clawdbot channels login --verbose
```

会显示 QR 码，用 WhatsApp 扫描即可连接。

### 发送 WhatsApp 消息

```bash
clawdbot message send --target +15555550123 --message "你好" --json
```

### 发送 Telegram 消息

```bash
clawdbot message send --channel telegram --target @mychat --message "你好"
```

### 与代理对话并发送回复

```bash
clawdbot agent --to +15555550123 --message "帮我总结一下今天的邮件" --deliver
```

## 配置文件

- **主配置**: `~/.clawdbot/clawdbot.json`
- **工作区**: `~/clawd`
- **会话目录**: `~/.clawdbot/agents/main/sessions`

## 命令行选项

| 选项 | 说明 |
|------|------|
| `-V, --version` | 显示版本号 |
| `--dev` | 开发模式（隔离状态，端口 19001） |
| `--profile <name>` | 使用命名配置文件 |
| `--no-color` | 禁用 ANSI 颜色 |
| `-h, --help` | 显示帮助信息 |

## 获取帮助

```bash
# 查看所有命令
clawdbot help

# 查看特定命令帮助
clawdbot <command> --help
```

## 技能 (Skills)

Clawdbot 使用 [AgentSkills](https://agentskills.io) 兼容的技能文件夹来扩展功能。

### 技能位置

| 位置 | 说明 | 优先级 |
|------|------|--------|
| `<workspace>/skills` | 工作区技能 | 最高 |
| `~/.clawdbot/skills` | 本地共享技能 | 中 |
| `skills.load.extraDirs` | 额外技能目录 | 最低 |
| 内置技能 | 随安装包提供 | 最低 |

### 本项目技能

本项目的技能位于 `./skills` 目录，通过 `extraDirs` 配置加载：

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/Users/lxt/Code/clawdbot/skills"]
    }
  }
}
```

### 创建技能

1. 在技能目录创建文件夹：

```bash
mkdir -p ~/clawd/skills/my-skill
```

2. 创建 `SKILL.md` 文件：

```markdown
---
name: my-skill
description: 技能描述
metadata: {"clawdbot":{"emoji":"🎯","requires":{"env":["API_KEY"]}}}
user-invocable: true
---

# 技能名称

技能说明和使用指令...
```

### Frontmatter 字段

| 字段 | 说明 |
|------|------|
| `name` | 技能名称（必填） |
| `description` | 技能描述（必填） |
| `metadata` | JSON 格式的元数据 |
| `user-invocable` | 是否可通过斜杠命令触发 |
| `homepage` | 技能主页 URL |

### metadata.clawdbot 配置

```json
{
  "clawdbot": {
    "emoji": "🎯",
    "homepage": "https://example.com",
    "requires": {
      "bins": ["python"],
      "env": ["API_KEY"],
      "config": ["feature.enabled"]
    },
    "primaryEnv": "API_KEY"
  }
}
```

### 配置技能

在 `~/.clawdbot/clawdbot.json` 中启用和配置技能：

```json
{
  "skills": {
    "entries": {
      "my-skill": {
        "enabled": true,
        "apiKey": "YOUR_API_KEY",
        "env": {
          "API_KEY": "YOUR_API_KEY"
        },
        "config": {
          "option1": "value1"
        }
      }
    }
  }
}
```

### 技能市场

浏览和安装社区技能：[clawdhub.com](https://clawdhub.com)

```bash
# 安装技能
clawdhub install <skill-slug>

# 更新所有技能
clawdhub update --all
```

## 文档

官方文档：[docs.clawd.bot/cli](https://docs.clawd.bot/cli)

## 版本

当前版本：**2026.1.24-3**
