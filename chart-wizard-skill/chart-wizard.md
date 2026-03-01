---
name: chart-wizard
description: 数据可视化向导 — 问询数据需求、分析文件结构、生成 pyecharts Python 脚本（HTML 输出），可选打包为 .exe
argument-hint: "[--resume]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Task
  - AskUserQuestion
---

<objective>
帮助用户将数据文件（xlsx/csv/json 等）处理后，生成基于 ECharts（通过 pyecharts）的交互式 HTML 图表，并可选打包为 Windows 可执行文件（.exe）。

**产出物：**
- `CHART-SPEC.md` — 图表规格文档（状态持久化，支持 --resume）
- `<脚本名>.py` — 完整 Python 脚本（数据处理 + 图表绘制）
- `<输出名>.html` — 生成的交互式图表（运行脚本后）
- （可选）`dist/<脚本名>.exe` — 打包后的可执行文件

**工作流阶段：**
1. INTAKE — 开放式问询，提取需求
2. DATA ANALYSIS — 分析数据文件真实结构
3. SPEC — 写入 CHART-SPEC.md，用户确认
4. CODE — 生成 Python 脚本，用户审查
5. PACKAGE（可选）— 打包为 .exe
</objective>

<context>
参数：$ARGUMENTS

**标志：**
- `--resume` — 从已有的 CHART-SPEC.md 恢复会话，跳过问询阶段
</context>

<execution_context>
@~/.claude/chart-wizard/workflow.md
@~/.claude/chart-wizard/questioning.md
</execution_context>

<process>
从 @~/.claude/chart-wizard/workflow.md 端到端执行图表向导工作流。
遵守所有工作流关卡（问询 → 分析 → 确认 → 生成 → 可选打包）。
遵守 @~/.claude/chart-wizard/questioning.md 中的问询哲学。
</process>
