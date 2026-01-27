---
name: daily-summary
description: 生成每日工作总结，包括完成的任务、会议和待办事项
metadata: {"clawdbot":{"emoji":"📊","requires":{"env":["OPENAI_API_KEY"]},"primaryEnv":"OPENAI_API_KEY"}}
user-invocable: true
---

# 每日总结技能

自动生成每日工作总结报告。

## 功能

- 📋 汇总今日完成的任务
- 📅 列出今日会议记录
- ✅ 整理待办事项
- 📈 生成工作效率分析

## 触发方式

用户可以通过以下方式触发：

- `/daily-summary` — 斜杠命令
- "生成今日总结"
- "帮我写日报"
- "总结一下今天的工作"

## 指令

当用户请求每日总结时，按以下步骤执行：

1. **收集信息**
   - 检查日历中今日的会议
   - 查看邮件中的重要事项
   - 获取任务管理系统中的已完成任务

2. **生成总结**
   - 按时间顺序整理事项
   - 分类：会议、任务、沟通
   - 标注重要程度

3. **输出格式**

```markdown
## 📊 每日工作总结 - {日期}

### ✅ 已完成
- [ ] 任务1
- [ ] 任务2

### 📅 会议
- 10:00 周会
- 14:00 项目讨论

### 📝 待跟进
- 事项1
- 事项2

### 💡 明日计划
- 计划1
- 计划2
```

## 配置

在 `~/.clawdbot/clawdbot.json` 中配置：

```json
{
  "skills": {
    "entries": {
      "daily-summary": {
        "enabled": true,
        "config": {
          "timezone": "Asia/Shanghai",
          "format": "markdown",
          "includeCalendar": true,
          "includeEmail": true
        }
      }
    }
  }
}
```

## 依赖

- 需要设置 `OPENAI_API_KEY` 环境变量
