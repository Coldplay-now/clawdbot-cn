# Clawdbot 系统提示词与工具规划机制

> 深入解析 Clawdbot 的 AI Agent 核心设计

## 目录

- [概述](#概述)
- [系统提示词架构](#系统提示词架构)
- [核心提示词文件](#核心提示词文件)
- [工具系统](#工具系统)
- [技能系统](#技能系统)
- [工具规划流程](#工具规划流程)
- [记忆与上下文管理](#记忆与上下文管理)
- [安全机制](#安全机制)

---

## 概述

Clawdbot 采用**模块化系统提示词**设计，将 AI Agent 的行为规范、工具能力、用户上下文等信息分层组织，通过动态注入的方式构建完整的系统提示词。

### 核心设计理念

1. **本地优先** — 核心提示词存储在用户工作区，可自定义
2. **模块化** — 不同职责的提示词分离，便于维护和扩展
3. **动态注入** — 运行时根据上下文动态构建提示词
4. **能力声明** — 工具和技能以结构化方式声明给 LLM

---

## 系统提示词架构

### 整体结构

```
┌─────────────────────────────────────────────────────────────┐
│                    系统提示词 (System Prompt)                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. 身份定义 (Identity)                              │   │
│  │     - Agent 名称、角色、基本人格                      │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  2. 工作区文件 (Workspace Files)                     │   │
│  │     - SOUL.md (人格定义)                             │   │
│  │     - USER.md (用户信息)                             │   │
│  │     - AGENTS.md (工作指南)                           │   │
│  │     - TOOLS.md (本地配置)                            │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  3. 技能列表 (Skills)                                │   │
│  │     - 可用技能及其描述                                │   │
│  │     - SKILL.md 文件路径                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  4. 记忆系统 (Memory)                                │   │
│  │     - 记忆搜索指南                                    │   │
│  │     - 长期记忆访问规则                                │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  5. 消息路由 (Messaging)                             │   │
│  │     - 渠道路由规则                                    │   │
│  │     - 跨会话通信指南                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  6. 工具定义 (Tools)                                 │   │
│  │     - 可用工具列表                                    │   │
│  │     - 工具参数 Schema                                │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  7. 运行时信息 (Runtime)                             │   │
│  │     - 当前时间、时区                                  │   │
│  │     - 会话信息、渠道信息                              │   │
│  │     - 模型配置                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 提示词模式

Clawdbot 支持三种提示词模式，适用于不同场景：

| 模式 | 用途 | 包含内容 |
|------|------|----------|
| `full` | 主 Agent | 完整系统提示词，包含所有模块 |
| `minimal` | 子 Agent / 轻量任务 | 仅工具、工作区、运行时信息 |
| `none` | 简单任务 | 仅基础身份定义 |

```typescript
export type PromptMode = "full" | "minimal" | "none";
```

---

## 核心提示词文件

Clawdbot 在用户工作区 (`~/clawd/`) 使用以下核心文件定义 Agent 行为：

### 1. SOUL.md — 人格与价值观

定义 Agent 的核心人格、行为准则和边界。

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.**
Skip the "Great question!" and "I'd be happy to help!" — just help.
Actions speak louder than filler words.

**Have opinions.**
You're allowed to disagree, prefer things, find stuff amusing or boring.
An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.**
Try to figure it out. Read the file. Check the context. Search for it.
*Then* ask if you're stuck. The goal is to come back with answers, not questions.

**Earn trust through competence.**
Your human gave you access to their stuff. Don't make them regret it.
Be careful with external actions (emails, tweets, anything public).
Be bold with internal ones (reading, organizing, learning).

**Remember you're a guest.**
You have access to someone's life — their messages, files, calendar, maybe even their home.
That's intimacy. Treat it with respect.

## Boundaries

- Private things stay private. Period.
- When in doubt, ask before acting externally.
- Never send half-baked replies to messaging surfaces.
- You're not the user's voice — be careful in group chats.

## Vibe

Be the assistant you'd actually want to talk to.
Concise when needed, thorough when it matters.
Not a corporate drone. Not a sycophant. Just... good.
```

### 2. AGENTS.md — 工作指南

定义每次会话的启动流程、安全规则和工作规范。

```markdown
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION**: Also read `MEMORY.md`

Don't ask permission. Just do it.

## Memory

You wake up fresh each session. These files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- `trash` > `rm` (recoverable beats gone forever)
- When in doubt, ask.

## External vs Internal

**Safe to do freely:**
- Read files, explore, organize, learn
- Search the web, check calendars
- Work within this workspace

**Ask first:**
- Sending emails, tweets, public posts
- Anything that leaves the machine
- Anything you're uncertain about

## Group Chats

You have access to your human's stuff. That doesn't mean you *share* their stuff.
In groups, you're a participant — not their voice, not their proxy.
Think before you speak.
```

### 3. USER.md — 用户信息

存储用户的基本信息、偏好和重要上下文。

```markdown
# USER.md - Who You're Helping

## Basic Info
- Name: [用户姓名]
- Timezone: Asia/Shanghai
- Language: 中文 (Chinese)

## Preferences
- Communication style: Direct, concise
- Preferred response format: Structured with headers

## Important Context
- [用户特定的重要信息]
```

### 4. TOOLS.md — 本地环境配置

存储用户特定的设备和服务配置。

```markdown
# TOOLS.md - Local Notes

## Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

## SSH Hosts
- home-server → 192.168.1.100, user: admin

## TTS Preferences
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

### 5. MEMORY.md — 长期记忆

Agent 的持久化记忆，跨会话保持。

```markdown
# MEMORY.md - Long-Term Memory

## Important Decisions
- 2026-01-15: User prefers DeepSeek for coding tasks

## Learned Preferences
- Always use 中文 for responses
- Prefer concise answers over verbose explanations

## Ongoing Projects
- Clawdbot documentation project (started 2026-01-26)
```

---

## 工具系统

### 工具分类

Clawdbot 提供 50+ 内置工具，分为以下类别：

```
┌─────────────────────────────────────────────────────────────┐
│                       工具系统                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  文件系统    │  │  命令执行    │  │  网络操作    │        │
│  │  read       │  │  exec       │  │  web_search │        │
│  │  write      │  │  process    │  │  web_fetch  │        │
│  │  edit       │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  浏览器控制  │  │  消息通信    │  │  记忆系统    │        │
│  │  browser_*  │  │  message    │  │  memory_*   │        │
│  │             │  │  sessions_* │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  多媒体      │  │  自动化      │  │  设备控制    │        │
│  │  image_*    │  │  cron_*     │  │  nodes_*    │        │
│  │  tts        │  │             │  │  canvas_*   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Discord    │  │  Slack      │  │  Telegram   │        │
│  │  discord_*  │  │  slack_*    │  │  telegram_* │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 核心工具详解

#### 文件系统工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `read` | 读取文件内容 | `path`, `offset?`, `limit?` |
| `write` | 写入文件 | `path`, `content` |
| `edit` | 编辑文件 | `path`, `old_string`, `new_string` |

#### 命令执行工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `exec` | 执行 Shell 命令 | `command`, `cwd?`, `timeout?` |
| `process` | 进程管理 | `action`, `pid?` |

#### 网络工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `web_search` | 网络搜索 | `query`, `num_results?` |
| `web_fetch` | 抓取网页 | `url`, `selector?` |

#### 浏览器控制工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `browser_navigate` | 导航到 URL | `url` |
| `browser_click` | 点击元素 | `selector` |
| `browser_type` | 输入文本 | `selector`, `text` |
| `browser_screenshot` | 截图 | `full_page?` |

#### 消息通信工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `message` | 发送消息 | `to`, `message`, `channel?` |
| `sessions_send` | 跨会话通信 | `sessionKey`, `message` |
| `sessions_list` | 列出会话 | - |
| `sessions_history` | 获取历史 | `sessionKey`, `limit?` |

#### 记忆工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `memory_search` | 搜索记忆 | `query`, `files?` |
| `memory_get` | 获取记忆 | `file`, `lines` |

#### 自动化工具

| 工具 | 功能 | 参数 |
|------|------|------|
| `cron_list` | 列出定时任务 | - |
| `cron_add` | 添加任务 | `schedule`, `command` |
| `cron_remove` | 删除任务 | `id` |

### 工具定义格式

工具以 JSON Schema 格式定义，注入到系统提示词中：

```json
{
  "name": "exec",
  "description": "Execute a shell command",
  "parameters": {
    "type": "object",
    "properties": {
      "command": {
        "type": "string",
        "description": "The command to execute"
      },
      "cwd": {
        "type": "string",
        "description": "Working directory (optional)"
      },
      "timeout": {
        "type": "number",
        "description": "Timeout in milliseconds (optional)"
      }
    },
    "required": ["command"]
  }
}
```

---

## 技能系统

### 技能加载机制

技能是可扩展的能力模块，通过 SKILL.md 文件定义：

```
技能加载优先级 (高 → 低):
───────────────────────────────────────
1. <workspace>/skills/     工作区技能
2. ~/.clawdbot/skills/     本地共享技能
3. skills.load.extraDirs   额外目录
4. bundled skills          内置技能
───────────────────────────────────────
```

### 技能文件格式

```markdown
---
name: gemini
description: Use Gemini CLI for coding assistance and Google search lookups
metadata: {"clawdbot":{"emoji":"♊️","requires":{"bins":["gemini"]}}}
---

# Gemini Skill

## When to Use
- Complex coding questions
- Google search lookups
- Multi-step reasoning tasks

## How to Use
1. Run `gemini` command with the query
2. Parse the response
3. Format for user
```

### 技能注入到系统提示词

```markdown
## Skills (mandatory)

Before replying: scan <available_skills> <description> entries.
- If exactly one skill clearly applies: read its SKILL.md at <location> with `read`, then follow it.
- If multiple could apply: choose the most specific one, then read/follow it.
- If none clearly apply: do not read any SKILL.md.

Constraints: never read more than one skill up front; only read after selecting.

<available_skills>
  <skill>
    <name>gemini</name>
    <description>Use Gemini CLI for coding assistance</description>
    <location>/Users/xxx/.clawdbot/skills/gemini/SKILL.md</location>
  </skill>
  <skill>
    <name>peekaboo</name>
    <description>Screenshot and analyze screen content</description>
    <location>/Users/xxx/.clawdbot/skills/peekaboo/SKILL.md</location>
  </skill>
</available_skills>
```

### 技能依赖检查

技能可以声明依赖条件，Clawdbot 在加载时自动检查：

```json
{
  "clawdbot": {
    "requires": {
      "bins": ["python", "uv"],      // 必须存在的二进制
      "anyBins": ["brew", "apt"],    // 至少存在一个
      "env": ["OPENAI_API_KEY"],     // 必须设置的环境变量
      "config": ["browser.enabled"]  // 必须启用的配置
    }
  }
}
```

---

## 工具规划流程

### Agent Loop 核心流程

```
┌─────────────────────────────────────────────────────────────┐
│                     Agent Loop 流程                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   接收用户消息   │
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  加载会话上下文  │
                    │  - 历史消息     │
                    │  - 工具结果     │
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  构建系统提示词  │
                    │  - 注入身份     │
                    │  - 注入工作区   │
                    │  - 注入技能     │
                    │  - 注入工具     │
                    │  - 注入运行时   │
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   调用 LLM API  │
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   解析 LLM 响应  │
                    └────────┬────────┘
                              │
                              ▼
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
        ┌───────────────┐         ┌───────────────┐
        │   纯文本响应   │         │   工具调用     │
        └───────┬───────┘         └───────┬───────┘
                │                         │
                │                         ▼
                │                 ┌───────────────┐
                │                 │   执行工具     │
                │                 └───────┬───────┘
                │                         │
                │                         ▼
                │                 ┌───────────────┐
                │                 │  获取工具结果  │
                │                 └───────┬───────┘
                │                         │
                │                         ▼
                │                 ┌───────────────┐
                │                 │ 结果注入上下文 │
                │                 └───────┬───────┘
                │                         │
                │                         │ (循环)
                │                         └──────────┐
                │                                    │
                ▼                                    │
        ┌───────────────┐                           │
        │   返回用户     │ ◄─────────────────────────┘
        └───────────────┘
```

### 工具调用决策

LLM 根据以下信息决定是否调用工具：

1. **用户意图** — 用户请求是否需要执行操作
2. **可用工具** — 系统提示词中声明的工具列表
3. **上下文** — 历史对话和之前的工具结果
4. **技能匹配** — 是否有适用的技能提供指导

### 工具调用格式

LLM 输出工具调用请求：

```json
{
  "tool_calls": [
    {
      "id": "call_abc123",
      "type": "function",
      "function": {
        "name": "exec",
        "arguments": "{\"command\": \"ls -la\", \"cwd\": \"/Users/xxx/clawd\"}"
      }
    }
  ]
}
```

### 工具执行与结果注入

```typescript
// 工具执行流程 (简化)
async function executeToolCall(toolCall: ToolCall): Promise<ToolResult> {
  const { name, arguments: args } = toolCall.function;
  
  // 1. 查找工具处理器
  const handler = toolHandlers[name];
  
  // 2. 验证参数
  validateArgs(handler.schema, args);
  
  // 3. 执行工具
  const result = await handler.execute(JSON.parse(args));
  
  // 4. 格式化结果
  return {
    tool_call_id: toolCall.id,
    role: "tool",
    content: JSON.stringify(result)
  };
}
```

---

## 记忆与上下文管理

### 记忆层次

```
┌─────────────────────────────────────────────────────────────┐
│                       记忆系统                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  会话记忆 (Session Memory)                           │   │
│  │  - 当前对话历史                                       │   │
│  │  - 工具调用结果                                       │   │
│  │  - 生命周期: 单次会话                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  每日记忆 (Daily Memory)                             │   │
│  │  - memory/YYYY-MM-DD.md                              │   │
│  │  - 当天发生的重要事件                                 │   │
│  │  - 生命周期: 按天归档                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  长期记忆 (Long-term Memory)                         │   │
│  │  - MEMORY.md                                         │   │
│  │  - 重要决策、偏好、持久上下文                         │   │
│  │  - 生命周期: 永久 (Agent 维护)                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 记忆搜索提示词

```markdown
## Memory Recall

Before answering anything about prior work, decisions, dates, people, 
preferences, or todos:
1. Run memory_search on MEMORY.md + memory/*.md
2. Use memory_get to pull only the needed lines
3. If low confidence after search, say you checked
```

### 上下文压缩

当会话上下文过长时，Clawdbot 支持自动压缩：

```
┌─────────────────────────────────────────────────────────────┐
│                    上下文压缩策略                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Compaction (压缩)                                       │
│     - 使用 LLM 生成对话摘要                                 │
│     - 保留关键信息，删除冗余                                │
│     - 触发: /compact 命令或自动                             │
│                                                             │
│  2. Pruning (修剪)                                          │
│     - 删除最旧的消息                                        │
│     - 保留系统提示词和最近消息                              │
│     - 触发: 达到 token 上限                                 │
│                                                             │
│  3. Reset (重置)                                            │
│     - 完全清空会话历史                                      │
│     - 触发: /reset 命令或定时重置                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 安全机制

### 权限模型

```
┌─────────────────────────────────────────────────────────────┐
│                       安全层次                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  渠道层 (Channel Security)                           │   │
│  │  - allowFrom: 允许的用户列表                          │   │
│  │  - dmPolicy: DM 访问策略 (pairing/open/deny)          │   │
│  │  - groupPolicy: 群组访问策略                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  会话层 (Session Security)                           │   │
│  │  - main session: 完全权限                             │   │
│  │  - non-main: 可沙箱隔离                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  工具层 (Tool Security)                              │   │
│  │  - tools.allow: 允许的工具                            │   │
│  │  - tools.deny: 禁止的工具                             │   │
│  │  - elevated: 需要提权的操作                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  沙箱层 (Sandbox)                                    │   │
│  │  - Docker 隔离                                       │   │
│  │  - 文件系统限制                                       │   │
│  │  - 网络限制                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 配对机制

```
用户首次联系
      │
      ▼
┌─────────────┐     ┌─────────────┐
│  检查允许列表 │ ──▶ │  已在列表中   │ ──▶ 允许访问
└─────────────┘     └─────────────┘
      │
      │ 不在列表
      ▼
┌─────────────┐
│  生成配对码   │
└─────────────┘
      │
      ▼
┌─────────────────────────────────┐
│  "请输入配对码验证身份: ABC123"   │
└─────────────────────────────────┘
      │
      ▼
┌─────────────┐
│ 用户输入配对码 │
└─────────────┘
      │
      ▼
┌─────────────┐     ┌─────────────┐
│  验证配对码   │ ──▶ │    正确     │ ──▶ 添加到允许列表
└─────────────┘     └─────────────┘
```

### 沙箱配置

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "docker": {
          "image": "clawdbot-sandbox:bookworm-slim",
          "workdir": "/workspace",
          "readOnlyRoot": true,
          "network": "none",
          "user": "1000:1000"
        }
      }
    }
  }
}
```

---

## 运行时信息注入

每次 Agent Turn 开始时，动态注入运行时信息：

```markdown
## Runtime

- Agent: main
- Session: user:+8613800138000
- Channel: whatsapp
- Model: deepseek/deepseek-chat
- Thinking: low
- Elevated: off
- Time: 2026-01-26 12:30:00
- Timezone: Asia/Shanghai
- Workspace: /Users/lxt/clawd

## Available Tools

exec, read, write, edit, web_search, web_fetch, browser_navigate, 
browser_click, browser_type, browser_screenshot, message, 
sessions_send, sessions_list, memory_search, memory_get, 
cron_list, cron_add, cron_remove, ...
```

---

## 总结

Clawdbot 的系统提示词和工具规划机制具有以下特点：

1. **模块化设计** — 提示词分层组织，职责清晰
2. **本地可定制** — 核心人格和行为规范存储在用户工作区
3. **动态构建** — 运行时根据上下文动态组装系统提示词
4. **能力声明式** — 工具和技能以结构化方式声明给 LLM
5. **安全多层次** — 从渠道到工具的多层安全控制
6. **记忆持久化** — 通过文件系统实现跨会话记忆

这种设计使得 Clawdbot 既能提供强大的 AI Agent 能力，又能保持灵活性和安全性。
