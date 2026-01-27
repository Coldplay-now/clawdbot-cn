# Clawdbot 中文汉化版 🇨🇳

> 🦞 **Clawdbot** — 个人 AI 助手，通过聊天应用自动化你的日常任务

[![原项目](https://img.shields.io/badge/原项目-clawdbot%2Fclawdbot-blue?style=flat-square&logo=github)](https://github.com/clawdbot/clawdbot)
[![官方文档](https://img.shields.io/badge/官方文档-docs.clawd.bot-green?style=flat-square)](https://docs.clawd.bot)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)

---

## ✨ 这是什么？

这是 [Clawdbot](https://github.com/clawdbot/clawdbot) 的 **中文汉化版本**，包含：

- 🌐 **Web UI 完整汉化** - 控制台界面全部中文化
- 📖 **中文使用文档** - 详细的使用指南和技术文档
- 🔧 **示例技能** - 开箱即用的中文技能模板
- 📊 **架构分析文档** - 深入的技术实现分析

### 控制台概览

![Clawdbot 中文控制台](assets/screenshot-cn.png)

### 频道管理

![频道管理页面](assets/screenshot-channels.png)

### AI 聊天

![AI 聊天界面](assets/screenshot-chat.png)

---

## 🔗 原项目链接

| 资源 | 链接 |
|------|------|
| **GitHub 仓库** | https://github.com/clawdbot/clawdbot |
| **官方文档** | https://docs.clawd.bot |
| **官方网站** | https://clawd.bot |
| **技能市场** | https://clawdhub.com |

---

## 📦 安装

```bash
curl -fsSL https://clawd.bot/install.sh | bash
```

安装完成后运行初始设置：

```bash
clawdbot setup
```

### 使用汉化版 Web UI

将本仓库的汉化 UI 部署到本地：

```bash
# 克隆本仓库
git clone https://github.com/Coldplay-now/clawdbot-cn.git
cd clawdbot-cn/source/ui

# 安装依赖并构建
pnpm install
pnpm build

# 复制到全局安装目录
cp -r ../dist/control-ui/* $(npm root -g)/clawdbot/dist/control-ui/

# 重启网关
clawdbot gateway
```

访问 http://127.0.0.1:18789/__clawdbot__/ 即可看到中文界面。

---

## 🚀 快速开始

### 1. 完整配置向导

```bash
clawdbot onboard
```

### 2. 启动网关服务

```bash
clawdbot gateway
```

### 3. 打开控制面板

```bash
clawdbot dashboard
```

---

## 📚 中文文档

本仓库包含以下中文文档：

| 文档 | 说明 |
|------|------|
| [Clawdbot使用指南.md](Clawdbot使用指南.md) | 完整的使用教程 |
| [Clawdbot架构设计文档.md](Clawdbot架构设计文档.md) | 系统架构分析（含 Mermaid 图） |
| [Clawdbot系统提示词与工具规划机制.md](Clawdbot系统提示词与工具规划机制.md) | 提示词设计和工具调用机制 |
| [Clawdbot-ReAct循环与可观测性机制分析.md](Clawdbot-ReAct循环与可观测性机制分析.md) | Agent 核心循环分析 |

---

## 🎯 核心功能

Clawdbot 是一个开源的个人 AI 助手，支持：

- 📧 管理邮件和收件箱
- 📅 日历管理和提醒
- ✈️ 航班自动值机
- 🔍 网页搜索和浏览
- 📁 文件操作
- ⏰ 定时任务和 Cron 调度
- 💬 多渠道消息（WhatsApp、Telegram、Discord、Slack 等）

---

## 📋 核心命令

| 命令 | 说明 |
|------|------|
| `clawdbot setup` | 初始化配置文件和工作区 |
| `clawdbot onboard` | 交互式配置向导 |
| `clawdbot gateway` | 启动 WebSocket 网关 |
| `clawdbot dashboard` | 打开控制面板 UI |
| `clawdbot tui` | 终端用户界面 |
| `clawdbot agent` | 与 AI 代理对话 |
| `clawdbot channels login` | 登录渠道 |
| `clawdbot skills` | 技能管理 |
| `clawdbot doctor` | 健康检查 |

更多命令请查看 [使用指南](Clawdbot使用指南.md)。

---

## 🛠️ 技能 (Skills)

本仓库包含示例技能：

```
skills/
├── hello-world/     # 简单示例技能
│   └── SKILL.md
└── daily-summary/   # 每日总结技能
    └── SKILL.md
```

### 加载本地技能

在 `~/.clawdbot/clawdbot.json` 中添加：

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/path/to/clawdbot-cn/skills"]
    }
  }
}
```

---

## ⚙️ 配置文件

| 路径 | 说明 |
|------|------|
| `~/.clawdbot/clawdbot.json` | 主配置文件 |
| `~/clawd` | 默认工作区 |
| `~/.clawdbot/agents/` | Agent 数据 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如需贡献汉化内容，请参考：
- Web UI 文件位于 `source/ui/src/ui/`
- 文档位于根目录

---

## 📄 许可证

本项目基于 [Clawdbot](https://github.com/clawdbot/clawdbot) 开源项目，遵循 MIT 许可证。

---

## 🙏 致谢

感谢 [Clawdbot](https://github.com/clawdbot/clawdbot) 团队的出色工作！
