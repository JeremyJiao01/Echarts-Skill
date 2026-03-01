<purpose>
图表向导工作流：从数据文件到交互式 HTML 图表，可选打包为 .exe。
遵守问询哲学（见 questioning.md）：提炼需求，不做问卷调查。
</purpose>

<ui_patterns>
## 阶段 Banner（每个主要阶段开始时输出）
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► {阶段名称}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Checkpoint 确认框（需用户操作时）
```
╔══════════════════════════════════════════════════╗
║  CHECKPOINT: {类型}                              ║
╚══════════════════════════════════════════════════╝

{内容}

──────────────────────────────────────────────────
→ {操作提示}
──────────────────────────────────────────────────
```

## 状态符号
- ✓ 完成 / 通过
- ✗ 失败 / 缺失
- ◆ 进行中
- ○ 待处理
- ⚠ 警告
</ui_patterns>

<process>

---

## 步骤 0：初始化检查

解析 `$ARGUMENTS`：
- 检测 `--resume` 标志 → 存为 `$RESUME_MODE`（true/false）
- 确定工作目录：数据文件和脚本默认放在同一目录

**如果 `$RESUME_MODE` 为 true：**

检查 `CHART-SPEC.md` 是否存在（在当前目录或用户说明的位置）。

- 如存在：读取 CHART-SPEC.md，展示当前状态摘要，询问：

  ```
  AskUserQuestion(
    header: "恢复点",
    question: "找到已有的 CHART-SPEC.md，你想从哪里继续？",
    options: [
      { label: "重新生成代码", description: "规格不变，重新生成 Python 脚本" },
      { label: "修改规格", description: "调整图表需求后重新生成" },
      { label: "直接打包", description: "代码已就绪，直接执行打包" }
    ]
  )
  ```

  根据选择跳转到对应步骤。

- 如不存在：提示「未找到 CHART-SPEC.md，将从头开始」，进入步骤 1。

**如果 `$RESUME_MODE` 为 false：** 直接进入步骤 1。

---

## 步骤 1：INTAKE — 开放式问询

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► INTAKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**遵守 questioning.md 中的所有问询原则。**

从这句话开始，让用户先倾诉：

「告诉我你的数据是什么，以及你想通过图表展示什么？」

**在问询过程中，必须搞清楚以下核心信息（不一定按顺序问，跟着对话走）：**

- [ ] 数据文件路径/名称（xlsx/csv/json 等）
- [ ] 数据大概内容（销售、财务、用户行为……）
- [ ] 图表想讲的故事/结论
- [ ] X 轴是什么，Y 轴是什么（或饼图的维度）
- [ ] 是否需要数据处理（筛选、聚合、时间范围……）
- [ ] 输出文件名（py 文件名、html 文件名）
- [ ] 图表标题

**不需要强制问的（可以有合理默认值）：**
- 图表尺寸（默认 100% × 600px）
- 颜色主题（默认 ECharts 默认色盘）
- 是否打包 exe（后面再问）

**使用 AskUserQuestion 帮用户思考**（见 questioning.md 的 askuserquestion_guide）：

关键选择点举例：
- 图表类型不明确时：提供「趋势/对比/占比/不确定」选项
- 颜色风格时：提供「商务/彩色/暗色/参考截图」选项
- 数据处理时：「按某列分组/筛选时间范围/排序取 TopN/不需要处理」

**Decision Gate（达到这里才进入步骤 2）：**

当你能写出完整 CHART-SPEC.md 时，执行问询决策关卡（见 questioning.md 的 decision_gate）。

---

## 步骤 2：DATA ANALYSIS — 数据文件分析

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► DATA ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ 分析数据文件结构...
```

**如果用户提供了数据文件路径，** 尝试读取文件：

**对于 Excel 文件：** 直接读取（如能访问），或使用 Bash 运行 Python 脚本分析：

```bash
python3 -c "
import pandas as pd
import json
df = pd.read_excel('<文件路径>', nrows=5)
info = {
    'columns': list(df.columns),
    'dtypes': {c: str(t) for c, t in df.dtypes.items()},
    'shape': list(df.shape),
    'sample': df.head(3).to_dict(orient='records')
}
print(json.dumps(info, ensure_ascii=False, default=str))
"
```

对于 CSV：将 `read_excel` 改为 `read_csv`。对于 JSON：改为 `read_json`。

**分析结果展示给用户：**

```
✓ 数据文件解析完成

文件：<路径>
行数：<N>   列数：<M>
列清单：
  - <列名1>（<数据类型>）
  - <列名2>（<数据类型>）
  ...

前 3 行样本：
<表格形式>
```

**根据实际列名，主动确认 X 轴/Y 轴映射：**

「根据你的数据，我理解：
- X 轴（分类/时间）→ `<列名>`
- Y 轴（数值）→ `<列名>`

是这样吗，还是需要调整？」

如果用户之前没说清楚数据处理需求，此时根据实际数据追问：
- 有空值：「数据里有空值，要如何处理？去除 / 用 0 填充 / 保留」
- 有时间列：「你想展示哪段时间范围？全部 / 最近 N 天 / 指定范围」
- 有分类列：「是否要按 `<列名>` 分组展示？」

**如果无法访问文件（路径不存在）：**

```
⚠ 无法读取文件：<路径>

请确认：
1. 文件路径是否正确？
2. 文件是否在当前目录下？

你也可以直接告诉我数据的列名和类型，我们继续。
```

让用户手动描述列结构后继续。

---

## 步骤 3：SPEC — 图表规格确认

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► SPEC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ 生成图表规格文档...
```

将所有收集到的信息写入 `CHART-SPEC.md`（写到用户的工作目录）：

```markdown
# CHART-SPEC.md
<!-- chart-wizard 状态文件。使用 /chart-wizard --resume 恢复会话 -->

## 数据源
- 文件路径：<路径>
- 文件格式：<xlsx/csv/json>
- Sheet/数据表：<名称或默认>
- 数据规模：<行数> 行 × <列数> 列

## 数据处理
```python
# 伪代码描述处理逻辑（生成代码时参考）
<处理步骤描述>
```

## 图表配置
- 图表类型：<Line/Bar/Pie/Scatter/...>
- 图表标题：<主标题>
- 副标题：<副标题，无则留空>
- X 轴：<列名> — <语义说明>
- Y 轴：<列名(s)> — <语义说明>
- 颜色主题：<DEFAULT/DARK/CHALK/ESSOS/...>
- 图表尺寸：<宽> × <高>
- 交互功能：<Tooltip/DataZoom/Legend 等>

## 输出配置
- Python 脚本名：<name>.py
- HTML 输出名：<name>.html
- 数据文件与脚本：<同目录 / 指定路径>

## 打包需求
- 是否打包 exe：<是 / 否 / 待定>
- 打包时数据文件：<随 exe 分发 / 内嵌 exe>
```

**CHECKPOINT — 用户确认规格：**

```
╔══════════════════════════════════════════════════╗
║  CHECKPOINT: 规格确认                            ║
╚══════════════════════════════════════════════════╝

CHART-SPEC.md 已写入，请确认以上规格是否正确。

──────────────────────────────────────────────────
→ 确认无误，可回复「确认」或指出需要修改的部分
──────────────────────────────────────────────────
```

如果用户要修改：更新 CHART-SPEC.md 对应字段，重新展示修改后的内容，再次确认。

循环直到用户确认规格无误。

---

## 步骤 4：CODE — 生成 Python 脚本

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► CODE GENERATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ 生成 Python 脚本...
```

根据 CHART-SPEC.md 生成完整的 Python 脚本，写入 `<name>.py`。

**代码结构模板：**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
图表生成脚本
生成工具：/chart-wizard（Apache ECharts Python 封装）
依赖：pip install pyecharts openpyxl pandas
"""

import os
import sys
import pandas as pd
from pyecharts import options as opts
from pyecharts.charts import <图表类>
from pyecharts.globals import ThemeType

# ── 0. 路径配置 ──────────────────────────────────────────────
# 兼容直接运行和 PyInstaller 打包两种模式
def _base_dir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

BASE_DIR    = _base_dir()
DATA_FILE   = os.path.join(BASE_DIR, "<数据文件名>")
OUTPUT_FILE = os.path.join(BASE_DIR, "<输出HTML文件名>")

# ── 1. 读取数据 ───────────────────────────────────────────────
df = pd.read_excel(DATA_FILE)   # 根据格式替换为 read_csv / read_json

# ── 2. 数据处理 ───────────────────────────────────────────────
# <根据 CHART-SPEC.md 中数据处理部分生成的 pandas 操作>

# ── 3. 图表绘制（pyecharts / ECharts API）────────────────────
chart = (
    <图表类>(init_opts=opts.InitOpts(
        width="<宽>",
        height="<高>",
        theme=ThemeType.<主题>
    ))
    .add_xaxis(<X 轴数据>)
    .add_yaxis("<系列名>", <Y 轴数据>)
    .set_global_opts(
        title_opts=opts.TitleOpts(
            title="<主标题>",
            subtitle="<副标题>"
        ),
        tooltip_opts=opts.TooltipOpts(trigger="axis"),
        legend_opts=opts.LegendOpts(pos_top="5%"),
        # <其他 global opts 按需添加>
    )
)

# ── 4. 输出 HTML ──────────────────────────────────────────────
chart.render(OUTPUT_FILE)
print(f"✓ 图表已生成：{OUTPUT_FILE}")
```

**代码质量要求：**
- `_base_dir()` 函数必须存在（兼容 exe 和直接运行）
- 所有路径用 `os.path.join(BASE_DIR, ...)` 拼接
- pyecharts API 调用必须正确（使用 v2.x API）
- 列名必须与步骤 2 分析到的实际列名一致
- 数据处理逻辑每步有注释

将完整脚本写入文件后展示给用户。

**CHECKPOINT — 代码审查：**

```
╔══════════════════════════════════════════════════╗
║  CHECKPOINT: 代码审查                            ║
╚══════════════════════════════════════════════════╝

<脚本名>.py 已生成，请查看以上代码。

──────────────────────────────────────────────────
→ 如有修改需求请说明，确认无误后回复「确认」
──────────────────────────────────────────────────
```

**处理反馈：**
- 用户要修改：定位修改点，用 Edit 工具修改文件，展示修改后相关代码，再次确认
- 循环直到用户确认代码无误

---

## 步骤 5：PACKAGE — 打包为 .exe（仅在用户确认后）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► PACKAGING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**首先确认打包意向（如果 CHART-SPEC.md 中「打包需求」为「待定」）：**

```
AskUserQuestion(
  header: "打包",
  question: "是否需要将 Python 脚本打包为 Windows .exe 文件？",
  options: [
    { label: "是，立即打包", description: "生成 PyInstaller 打包指令" },
    { label: "否，不需要", description: "到此结束" }
  ]
)
```

**如果打包：**

确认数据文件处理方式：

```
AskUserQuestion(
  header: "数据文件",
  question: "exe 运行时数据文件如何处理？",
  options: [
    { label: "与 exe 放同目录", description: "用户手动放置，脚本已处理好路径（推荐）" },
    { label: "内嵌进 exe", description: "数据打包进去，用户不需要单独文件" }
  ]
)
```

**方案 A：数据文件与 exe 同目录（已通过 `_base_dir()` 处理，无需修改代码）**

提供打包命令：

```
📦 打包步骤

1. 安装依赖（如未安装）：
   pip install pyecharts openpyxl pandas pyinstaller

2. 运行打包命令：
   pyinstaller --onefile --name "<脚本名>" "<脚本名>.py"

3. 打包完成后：
   - exe 位于 dist/<脚本名>.exe
   - 将 <数据文件名> 复制到 dist/ 目录下（与 exe 同级）
   - 双击 exe 运行，生成 <输出名>.html 在同目录

⚠ 注意：pyecharts 使用在线 CDN 加载 ECharts.js，目标机器需联网。
  如需离线运行，请告知，我会提供离线配置方案。
```

**方案 B：数据文件内嵌 exe**

先修改脚本中的 `_base_dir()` 函数（已有 `sys._MEIPASS` 分支），然后提供打包命令：

```bash
pyinstaller --onefile \
  --add-data "<数据文件名>:." \
  --name "<脚本名>" \
  "<脚本名>.py"
```

并说明：内嵌数据在运行时解压到临时目录，通过 `sys._MEIPASS` 访问，路径逻辑已在代码中处理。

---

## 步骤 6：完成总结

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CHART WIZARD ► 完成 ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

输出交付物清单：

```
✓ CHART-SPEC.md        — 图表规格文档（用于 --resume 恢复）
✓ <脚本名>.py          — Python 数据处理 + 图表生成脚本
○ <输出名>.html        — 运行脚本后生成
<打包状态>
```

---

## 会话恢复（--resume 时的详细处理）

读取 CHART-SPEC.md 后，解析各字段，构建当前状态摘要展示给用户：

```
◆ 恢复会话

规格文件：CHART-SPEC.md
---
数据源：<路径>
图表类型：<类型>
标题：<标题>
脚本：<脚本名>.py  → <状态>
打包：<状态>
```

根据用户选择跳转到对应步骤（步骤 3/4/5）。

</process>

<success_criteria>
- [ ] 步骤 0：检测 --resume 并正确路由
- [ ] 步骤 1：遵守问询哲学，核心信息全部收集，decision gate 通过
- [ ] 步骤 2：成功读取文件结构并展示，X/Y 轴映射确认
- [ ] 步骤 3：CHART-SPEC.md 写入并经用户确认
- [ ] 步骤 4：Python 脚本生成，路径用 _base_dir()，列名与实际数据一致，经用户审查通过
- [ ] 步骤 5（可选）：提供正确的 PyInstaller 命令，说明数据文件处理方式
- [ ] 步骤 6：展示完整交付物清单
</success_criteria>
