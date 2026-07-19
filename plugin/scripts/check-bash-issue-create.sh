#!/bin/sh
# HDD issue-hypothesis-gate: PreToolUse hook for the Bash tool.
# Blocks ticket-creation commands (gh issue create 等) that carry no hypothesis marker.
# POSIX sh only. Depends on jq; fails open if jq is unavailable.

set -eu

if [ "${HDD_HOOK_DISABLE:-}" = "1" ]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

command_str="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
if [ -z "$command_str" ]; then
  exit 0
fi

# チケット作成コマンドか判定（該当しなければ何もせず許可）
if ! printf '%s' "$command_str" | grep -qE 'gh[[:space:]]+issue[[:space:]]+create|glab[[:space:]]+issue[[:space:]]+create|jira[[:space:]]+issue[[:space:]]+create'; then
  exit 0
fi

# 仮説・検証マーカーの有無を判定
if printf '%s' "$command_str" | grep -qE '仮説|Hypothesis|検証|Verification|成功基準|Success criteria|\[no-hypothesis\]'; then
  exit 0
fi

cat >&2 <<'EOF'
仮説・検証セクションの無いチケット作成をブロックした。
/hdd:issue を使うか、本文に仮説セクション（仮説・検証方法・成功基準）を追加せよ。
ユーザーが仮説不要と明示した場合のみ、[no-hypothesis] マーカーを本文に含めて再実行せよ。
EOF
exit 2
