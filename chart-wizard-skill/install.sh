#!/usr/bin/env bash
# chart-wizard skill 安装脚本
# 用法：bash install.sh

set -e

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
WORKFLOW_DIR="$HOME/.claude/chart-wizard"

echo "安装 chart-wizard skill..."

mkdir -p "$COMMANDS_DIR"
mkdir -p "$WORKFLOW_DIR"

cp "$SKILL_DIR/chart-wizard.md"  "$COMMANDS_DIR/chart-wizard.md"
cp "$SKILL_DIR/workflow.md"      "$WORKFLOW_DIR/workflow.md"
cp "$SKILL_DIR/questioning.md"   "$WORKFLOW_DIR/questioning.md"

echo "✓ 安装完成"
echo "  命令文件：$COMMANDS_DIR/chart-wizard.md"
echo "  工作流  ：$WORKFLOW_DIR/"
echo ""
echo "重启 Claude Code 后使用 /chart-wizard 启动"
