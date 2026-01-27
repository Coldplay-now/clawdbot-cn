---
name: hello-world
description: 一个简单的示例技能，演示如何创建 Clawdbot 技能
metadata: {"clawdbot":{"emoji":"👋","homepage":"https://github.com/your-repo/hello-world"}}
---

# Hello World 技能

这是一个示例技能，用于演示 Clawdbot 技能的基本结构。

## 功能

当用户请求打招呼或测试技能时，使用此技能。

## 使用方式

用户可以通过以下方式触发此技能：

- "打个招呼"
- "测试 hello world"
- "运行示例技能"

## 指令

当用户请求使用此技能时：

1. 用友好的方式打招呼
2. 告诉用户当前时间
3. 提供一个有趣的每日一句

## 示例对话

**用户**: 打个招呼
**助手**: 你好！👋 现在是 2026年1月26日。今日一句：代码如诗，优雅而有力。

## 扩展

你可以在 `{baseDir}` 目录下添加更多文件来扩展此技能：

- `prompts/` — 提示词模板
- `scripts/` — 辅助脚本
- `data/` — 数据文件
