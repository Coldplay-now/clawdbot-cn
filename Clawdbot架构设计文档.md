# Clawdbot 系统架构设计文档

> 🦞 Clawdbot — 个人 AI 助手系统架构分析

## 目录

- [系统概述](#系统概述)
- [核心架构](#核心架构)
- [数据流程](#数据流程)
- [核心组件详解](#核心组件详解)
- [消息处理流程](#消息处理流程)
- [Agent 运行机制](#agent-运行机制)
- [技术栈](#技术栈)

---

## 系统概述

Clawdbot 是一个**本地优先**的个人 AI 助手系统，采用 Gateway 作为核心控制平面，支持多渠道消息接入和多工具调用。

### 核心特点

- **本地运行**：Gateway 运行在用户设备上，数据不经过第三方服务器
- **多渠道支持**：WhatsApp、Telegram、Discord、Slack 等 10+ 渠道
- **多模型支持**：Anthropic、OpenAI、DeepSeek、Gemini 等
- **工具调用**：文件操作、命令执行、浏览器控制、定时任务等
- **多代理协作**：支持多个隔离的 Agent 实例

---

## 核心架构

### 整体架构图

```mermaid
graph TB
    subgraph 用户层["👤 用户层"]
        WA[WhatsApp]
        TG[Telegram]
        DC[Discord]
        SL[Slack]
        WC[WebChat]
        TUI[Terminal UI]
        MAC[macOS App]
    end

    subgraph 网关层["🦞 Gateway 控制平面"]
        GW[Gateway Server<br/>ws://127.0.0.1:18789]
        RT[路由引擎<br/>Routing]
        CH[渠道管理<br/>Channels]
        SS[会话管理<br/>Sessions]
        QU[消息队列<br/>Queue]
    end

    subgraph Agent层["🤖 Agent 运行时"]
        AG[Pi Agent Runtime]
        LLM[LLM Provider<br/>Claude/GPT/DeepSeek]
        TL[工具层<br/>Tools]
        SK[技能层<br/>Skills]
        MM[记忆系统<br/>Memory]
    end

    subgraph 工具层["🔧 工具 & 能力"]
        EX[Exec 命令执行]
        FS[文件系统]
        BR[浏览器控制]
        CR[Cron 定时任务]
        ND[Nodes 设备控制]
        CV[Canvas 可视化]
    end

    subgraph 存储层["💾 持久化"]
        CF[配置文件<br/>~/.clawdbot/]
        SN[会话存储<br/>sessions/]
        WS[工作区<br/>~/clawd/]
        CR2[凭证存储<br/>credentials/]
    end

    WA & TG & DC & SL & WC & TUI & MAC --> GW
    GW --> RT
    RT --> CH
    RT --> SS
    RT --> QU
    QU --> AG
    AG <--> LLM
    AG --> TL
    AG --> SK
    AG <--> MM
    TL --> EX & FS & BR & CR & ND & CV
    SS --> SN
    GW --> CF
    AG --> WS
    CH --> CR2
```

### 分层架构

```mermaid
graph LR
    subgraph L1["接入层"]
        A1[消息渠道适配器]
        A2[WebSocket API]
        A3[HTTP API]
    end

    subgraph L2["控制层"]
        B1[Gateway 服务]
        B2[路由 & 分发]
        B3[认证 & 授权]
    end

    subgraph L3["业务层"]
        C1[Agent 运行时]
        C2[会话管理]
        C3[工具调度]
    end

    subgraph L4["能力层"]
        D1[LLM 调用]
        D2[工具执行]
        D3[技能加载]
    end

    subgraph L5["存储层"]
        E1[配置存储]
        E2[会话持久化]
        E3[凭证管理]
    end

    L1 --> L2 --> L3 --> L4 --> L5
```

---

## 数据流程

### 消息处理完整流程

```mermaid
sequenceDiagram
    participant U as 用户
    participant C as 渠道<br/>(WhatsApp/TG)
    participant G as Gateway
    participant R as 路由引擎
    participant Q as 消息队列
    participant A as Agent
    participant L as LLM
    participant T as 工具

    U->>C: 发送消息
    C->>G: WebSocket 推送
    G->>R: 解析 & 路由
    R->>R: 权限检查<br/>allowFrom/pairing
    R->>Q: 入队
    Q->>A: 触发 Agent Turn
    
    loop Agent Loop
        A->>L: 构建 Prompt<br/>发送请求
        L-->>A: 返回响应/工具调用
        
        alt 需要工具调用
            A->>T: 执行工具
            T-->>A: 返回结果
            A->>L: 继续对话
        end
    end
    
    A->>G: 生成回复
    G->>C: 发送消息
    C->>U: 显示回复
```

### 多渠道路由机制

```mermaid
flowchart TD
    MSG[收到消息] --> PARSE[解析消息来源]
    PARSE --> CHECK{权限检查}
    
    CHECK -->|未授权| PAIR[发送配对码]
    CHECK -->|已授权| ROUTE[路由决策]
    
    ROUTE --> TYPE{消息类型}
    TYPE -->|私聊 DM| DM_SESS[个人会话]
    TYPE -->|群聊 Group| GRP_CHECK{@提及检查}
    
    GRP_CHECK -->|需要@| MENTION{是否@机器人}
    GRP_CHECK -->|不需要| GRP_SESS[群组会话]
    
    MENTION -->|是| GRP_SESS
    MENTION -->|否| IGNORE[忽略]
    
    DM_SESS --> QUEUE[消息队列]
    GRP_SESS --> QUEUE
    
    QUEUE --> AGENT[Agent 处理]
    
    style MSG fill:#e1f5fe
    style AGENT fill:#c8e6c9
    style IGNORE fill:#ffcdd2
```

---

## 核心组件详解

### 1. Gateway 服务

Gateway 是整个系统的**控制平面**，负责：

```mermaid
graph TB
    subgraph Gateway["Gateway 核心职责"]
        WS[WebSocket 服务器]
        HTTP[HTTP API]
        AUTH[认证管理]
        CONF[配置热加载]
        LOG[日志系统]
    end

    subgraph 子系统
        CH_MGR[渠道管理器]
        SESS_MGR[会话管理器]
        CRON_MGR[Cron 调度器]
        HOOK_MGR[Webhook 处理]
        NODE_MGR[节点管理器]
    end

    WS --> CH_MGR
    WS --> SESS_MGR
    HTTP --> HOOK_MGR
    AUTH --> CH_MGR
    CONF --> CRON_MGR
    WS --> NODE_MGR
```

**关键配置**：
```json
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "loopback",
    "auth": { "mode": "token" }
  }
}
```

### 2. Agent 运行时

Agent 是核心的 AI 推理引擎：

```mermaid
stateDiagram-v2
    [*] --> Idle: 初始化
    Idle --> Processing: 收到消息
    Processing --> LLMCall: 构建 Prompt
    LLMCall --> ToolExec: 需要工具
    LLMCall --> Response: 直接回复
    ToolExec --> LLMCall: 工具结果
    Response --> Idle: 发送完成
    
    state Processing {
        [*] --> LoadContext
        LoadContext --> BuildPrompt
        BuildPrompt --> InjectSkills
        InjectSkills --> [*]
    }
    
    state ToolExec {
        [*] --> ParseTool
        ParseTool --> Execute
        Execute --> FormatResult
        FormatResult --> [*]
    }
```

**Agent Loop 流程**：

```mermaid
flowchart LR
    A[用户输入] --> B[加载上下文]
    B --> C[注入系统提示]
    C --> D[注入技能]
    D --> E[调用 LLM]
    E --> F{响应类型}
    F -->|文本| G[返回用户]
    F -->|工具调用| H[执行工具]
    H --> I[获取结果]
    I --> E
    G --> J[保存会话]
```

### 3. 渠道适配器

每个消息渠道都有独立的适配器：

```mermaid
graph TB
    subgraph Channels["渠道适配器架构"]
        BASE[基础渠道接口]
        
        WA_ADAPT[WhatsApp 适配器<br/>Baileys]
        TG_ADAPT[Telegram 适配器<br/>grammY]
        DC_ADAPT[Discord 适配器<br/>discord.js]
        SL_ADAPT[Slack 适配器<br/>Bolt]
        SG_ADAPT[Signal 适配器<br/>signal-cli]
        IM_ADAPT[iMessage 适配器<br/>imsg]
    end
    
    BASE --> WA_ADAPT
    BASE --> TG_ADAPT
    BASE --> DC_ADAPT
    BASE --> SL_ADAPT
    BASE --> SG_ADAPT
    BASE --> IM_ADAPT
    
    subgraph 统一接口
        SEND[send]
        RECV[onMessage]
        STATUS[getStatus]
        LOGIN[login]
    end
    
    WA_ADAPT -.-> SEND & RECV & STATUS & LOGIN
```

### 4. 工具系统

```mermaid
graph TB
    subgraph Tools["工具分类"]
        subgraph 系统工具
            EXEC[exec<br/>命令执行]
            READ[read<br/>文件读取]
            WRITE[write<br/>文件写入]
            EDIT[edit<br/>文件编辑]
        end
        
        subgraph 高级工具
            BROWSER[browser<br/>浏览器控制]
            CANVAS[canvas<br/>可视化]
            NODES[nodes<br/>设备控制]
        end
        
        subgraph 自动化工具
            CRON[cron<br/>定时任务]
            WEBHOOK[webhook<br/>钩子触发]
            GMAIL[gmail<br/>邮件监控]
        end
        
        subgraph 协作工具
            SESS_LIST[sessions_list]
            SESS_SEND[sessions_send]
            AGENT_SPAWN[agent_spawn]
        end
    end
    
    AGENT[Agent] --> EXEC & READ & WRITE & EDIT
    AGENT --> BROWSER & CANVAS & NODES
    AGENT --> CRON & WEBHOOK & GMAIL
    AGENT --> SESS_LIST & SESS_SEND & AGENT_SPAWN
```

### 5. 技能系统 (Skills)

```mermaid
flowchart TD
    subgraph 技能加载顺序
        BUNDLED[内置技能<br/>bundled] --> MANAGED[管理技能<br/>~/.clawdbot/skills]
        MANAGED --> WORKSPACE[工作区技能<br/>~/clawd/skills]
        WORKSPACE --> EXTRA[额外目录<br/>extraDirs]
    end
    
    subgraph 技能结构
        SKILL_MD[SKILL.md]
        META[YAML Frontmatter]
        INST[指令内容]
        
        SKILL_MD --> META
        SKILL_MD --> INST
    end
    
    subgraph 加载过滤
        META --> CHECK{依赖检查}
        CHECK -->|bins 存在| LOAD[加载技能]
        CHECK -->|env 设置| LOAD
        CHECK -->|config 启用| LOAD
        CHECK -->|不满足| SKIP[跳过]
    end
```

---

## 消息处理流程

### 完整消息生命周期

```mermaid
flowchart TB
    subgraph 入站["📥 入站处理"]
        IN1[消息到达] --> IN2[渠道解析]
        IN2 --> IN3[身份识别]
        IN3 --> IN4[权限验证]
        IN4 --> IN5[消息规范化]
        IN5 --> IN6[入队]
    end
    
    subgraph 处理["⚙️ Agent 处理"]
        PR1[出队] --> PR2[加载会话上下文]
        PR2 --> PR3[构建系统提示]
        PR3 --> PR4[注入技能]
        PR4 --> PR5[调用 LLM]
        PR5 --> PR6{响应类型}
        PR6 -->|工具调用| PR7[执行工具]
        PR7 --> PR5
        PR6 -->|文本| PR8[生成回复]
    end
    
    subgraph 出站["📤 出站处理"]
        OUT1[回复内容] --> OUT2[格式化]
        OUT2 --> OUT3[分块/流式]
        OUT3 --> OUT4[渠道适配]
        OUT4 --> OUT5[发送]
    end
    
    IN6 --> PR1
    PR8 --> OUT1
```

### 队列模式

```mermaid
graph LR
    subgraph Queue["消息队列模式"]
        IMMEDIATE[immediate<br/>立即处理]
        COLLECT[collect<br/>收集合并]
        DEBOUNCE[debounce<br/>防抖]
    end
    
    MSG1[消息1] --> IMMEDIATE --> PROC1[立即处理]
    
    MSG2[消息2] --> COLLECT
    MSG3[消息3] --> COLLECT
    COLLECT --> |等待间隔| PROC2[批量处理]
    
    MSG4[连续消息] --> DEBOUNCE --> |最后一条| PROC3[处理]
```

---

## Agent 运行机制

### Agent 配置架构

```mermaid
graph TB
    subgraph Config["Agent 配置层次"]
        DEFAULT[默认配置<br/>agents.defaults]
        AGENT[Agent 配置<br/>agents.entries]
        SESSION[会话配置<br/>session override]
    end
    
    DEFAULT --> AGENT --> SESSION
    
    subgraph 配置项
        MODEL[model<br/>主模型]
        FALLBACK[fallbacks<br/>备选模型]
        WORKSPACE[workspace<br/>工作区]
        SANDBOX[sandbox<br/>沙箱模式]
        TIMEOUT[timeout<br/>超时设置]
    end
```

### 多 Agent 隔离

```mermaid
graph TB
    subgraph MultiAgent["多 Agent 架构"]
        MAIN[main Agent<br/>主会话]
        WORK[work Agent<br/>工作会话]
        TEST[test Agent<br/>测试会话]
    end
    
    subgraph 隔离项
        WS[独立工作区]
        SS[独立会话]
        AUTH[独立认证]
        SKILL[独立技能]
    end
    
    MAIN --> WS & SS & AUTH & SKILL
    WORK --> WS & SS & AUTH & SKILL
    TEST --> WS & SS & AUTH & SKILL
    
    ROUTE[渠道路由] --> |规则匹配| MAIN
    ROUTE --> |规则匹配| WORK
    ROUTE --> |规则匹配| TEST
```

### 会话管理

```mermaid
stateDiagram-v2
    [*] --> New: 新会话
    New --> Active: 首条消息
    Active --> Active: 持续对话
    Active --> Idle: 空闲超时
    Idle --> Active: 新消息
    Idle --> Reset: 重置触发
    Active --> Reset: /reset 命令
    Reset --> New: 清空上下文
    Active --> Compact: 上下文过长
    Compact --> Active: 压缩完成
```

---

## 技术栈

### 核心技术

```mermaid
mindmap
    root((Clawdbot))
        运行时
            Node.js 22+
            TypeScript
            Bun 可选
        构建
            pnpm
            Vitest
            tsc
        网络
            WebSocket
            HTTP/HTTPS
            Tailscale
        渠道
            Baileys WhatsApp
            grammY Telegram
            discord.js
            Bolt Slack
        LLM
            Anthropic API
            OpenAI API
            自定义 Provider
        存储
            JSON 配置
            JSONL 日志
            SQLite 可选
```

### 目录结构

```
clawdbot/
├── src/                    # 核心源码
│   ├── gateway/           # Gateway 服务
│   ├── agents/            # Agent 运行时
│   ├── channels/          # 渠道适配器
│   ├── cli/               # CLI 命令
│   ├── commands/          # 命令处理
│   ├── config/            # 配置管理
│   ├── cron/              # 定时任务
│   ├── browser/           # 浏览器控制
│   ├── memory/            # 记忆系统
│   ├── hooks/             # Webhook
│   ├── telegram/          # Telegram 适配
│   ├── discord/           # Discord 适配
│   ├── slack/             # Slack 适配
│   └── ...
├── apps/                   # 原生应用
│   ├── macos/             # macOS 菜单栏应用
│   ├── ios/               # iOS 节点应用
│   └── android/           # Android 节点应用
├── extensions/            # 扩展插件
├── skills/                # 内置技能
├── docs/                  # 文档
└── ui/                    # Web UI
```

---

## 安全模型

```mermaid
flowchart TD
    subgraph 安全层
        DM_PAIR[DM 配对机制]
        ALLOW[允许列表]
        SANDBOX[沙箱隔离]
        ELEVATED[提权控制]
    end
    
    MSG[收到消息] --> DM_PAIR
    DM_PAIR --> |已配对| ALLOW
    DM_PAIR --> |未配对| PAIR_CODE[发送配对码]
    
    ALLOW --> |在列表| AGENT[Agent 处理]
    ALLOW --> |不在| REJECT[拒绝]
    
    AGENT --> SANDBOX{沙箱模式}
    SANDBOX --> |main 会话| HOST[主机执行]
    SANDBOX --> |非 main| DOCKER[Docker 沙箱]
    
    AGENT --> ELEVATED{提权操作}
    ELEVATED --> |已授权| EXEC[执行]
    ELEVATED --> |未授权| DENY[拒绝]
```

---

## 部署架构

### 本地部署

```mermaid
graph TB
    subgraph Local["本地部署"]
        USER[用户设备]
        GW[Gateway<br/>127.0.0.1:18789]
        AGENT[Agent]
        
        USER --> GW --> AGENT
    end
    
    subgraph External["外部服务"]
        WA_SRV[WhatsApp 服务器]
        TG_SRV[Telegram Bot API]
        LLM_API[LLM API]
    end
    
    GW <--> WA_SRV
    GW <--> TG_SRV
    AGENT <--> LLM_API
```

### 远程部署

```mermaid
graph TB
    subgraph Remote["远程 Gateway (Linux)"]
        GW[Gateway]
        AGENT[Agent]
    end
    
    subgraph Local["本地设备"]
        MAC[macOS App]
        IOS[iOS Node]
        AND[Android Node]
    end
    
    subgraph Tunnel["安全隧道"]
        TS[Tailscale]
        SSH[SSH Tunnel]
    end
    
    MAC & IOS & AND --> TS & SSH --> GW
    GW --> AGENT
```

---

## 总结

Clawdbot 采用**本地优先、Gateway 中心化**的架构设计：

1. **Gateway** 作为统一控制平面，管理所有渠道连接和消息路由
2. **Agent** 作为 AI 推理引擎，处理对话和工具调用
3. **多渠道适配器** 统一接口，支持 10+ 消息平台
4. **技能系统** 提供可扩展的能力增强
5. **安全模型** 通过配对、允许列表、沙箱实现多层防护

这种架构使得 Clawdbot 既能保持本地数据隐私，又能灵活扩展和部署。
