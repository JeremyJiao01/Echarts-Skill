# Echarts-Skill

基于 [Apache ECharts](https://echarts.apache.org/) 的 Claude Code Agent Skill 集合，帮助你通过对话式交互将数据文件快速转化为交互式图表。

---

## Skills

### `/chart-wizard` — 数据可视化向导

从原始数据文件（xlsx / csv / json）出发，经过问询、数据分析、代码生成，输出可直接运行的 Python 脚本和交互式 HTML 图表，可选打包为 Windows `.exe`。

**核心流程：**

```
问询需求  →  分析数据文件结构  →  确认规格（CHART-SPEC.md）
    →  生成 Python 脚本  →  输出 HTML  →  （可选）打包 .exe
```

**产出物：**

| 文件 | 说明 |
|---|---|
| `CHART-SPEC.md` | 图表规格文档，支持 `--resume` 恢复会话 |
| `<name>.py` | 数据处理 + pyecharts 绘图脚本 |
| `<name>.html` | 运行脚本后生成的交互式 ECharts 图表 |
| `dist/<name>.exe` | （可选）PyInstaller 打包的可执行文件 |

**支持的图表类型：** 折线图、柱状图、饼图/环形图、散点图、热力图、雷达图、面积图、K 线图、桑基图等（pyecharts 全系列）

**数据处理能力：** 自动识别文件结构 → 生成 pandas 清洗/筛选/聚合代码，兼容混合日期格式、空值处理、多维度分组等场景。

---

## 安装

```bash
bash chart-wizard-skill/install.sh
```

重启 Claude Code 后生效。安装后文件位置：

```
~/.claude/commands/chart-wizard.md   ← 命令入口
~/.claude/chart-wizard/
  workflow.md                        ← 工作流逻辑
  questioning.md                     ← 问询哲学指南
```

---

## 使用

在 Claude Code 中输入：

```
/chart-wizard
```

按向导提示操作：提供数据文件路径和可视化需求，skill 会自动完成剩余工作。

**恢复上次会话：**

```
/chart-wizard --resume
```

从当前目录的 `CHART-SPEC.md` 恢复，跳过问询直接继续。

---

## 依赖

运行生成的 Python 脚本需要：

```bash
pip install pyecharts openpyxl pandas
```

打包为 `.exe` 额外需要：

```bash
pip install pyinstaller
```

---

## 文件结构

```
Echarts-Skill/
└── chart-wizard-skill/
    ├── chart-wizard.md    # Claude Code 命令入口
    ├── workflow.md        # 完整工作流（5 个阶段）
    ├── questioning.md     # 问询哲学：梦想提取而非问卷调查
    └── install.sh         # 一键安装脚本
```

---

## 设计理念

Skill 的问询和工作流设计参考了 [get-shit-done](https://github.com/glittercowboy/get-shit-done) 的上下文工程思路：

- **梦想提取而非问卷调查** — 开放式问询，跟着用户思路走，挑战模糊答案
- **状态持久化** — `CHART-SPEC.md` 写入磁盘，会话中断后可恢复
- **阶段关卡** — 每个关键节点用户显式确认，避免方向偏差
- **Subagent 数据分析** — 读取真实文件结构，代码列名与数据一致
