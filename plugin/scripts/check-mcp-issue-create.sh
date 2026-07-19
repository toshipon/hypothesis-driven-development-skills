#!/bin/sh
# HDD issue-hypothesis-gate: PreToolUse hook for MCP issue/backlog/ticket creation tools.
# Blocks tool calls whose tool_input carries no hypothesis marker.
# POSIX sh only. Depends on jq; fails open if jq is unavailable.

set -eu

if [ "${HDD_HOOK_DISABLE:-}" = "1" ]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input="$(cat)"

tool_input_str="$(printf '%s' "$input" | jq -c '.tool_input // {}')"

# 仮説・検証マーカーの有無を判定
if printf '%s' "$tool_input_str" | grep -qE '仮説|Hypothesis|検証|Verification|成功基準|Success criteria|\[no-hypothesis\]'; then
  exit 0
fi

cat >&2 <<'EOF'
仮説・検証セクションの無いチケット作成をブロックした。
/hdd:issue を使うか、本文に仮説セクション（仮説・検証方法・成功基準）を追加せよ。
ユーザーが仮説不要と明示した場合のみ、[no-hypothesis] マーカーを本文に含めて再実行せよ。
EOF
exit 2
