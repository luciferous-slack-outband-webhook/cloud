#!/bin/bash
set -euo pipefail

# Claude Code Stop Hook: 作業ログの存在をチェックする
# claude_logs/ 以外のファイル変更があるのにログが未作成ならブロックする

# stdin から JSON を読み取り
INPUT=$(cat)

# 無限ループ防止: 既に stop hook で継続中ならスキップ
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# 作業ディレクトリを取得
CWD=$(echo "$INPUT" | jq -r '.cwd')
LOG_DIR="$CWD/claude_logs"

cd "$CWD"

# git で claude_logs/ 以外の変更があるかチェック
GIT_CHANGES=$(git diff --name-only HEAD 2>/dev/null | grep -v '^claude_logs/' || true)
STAGED_CHANGES=$(git diff --cached --name-only 2>/dev/null | grep -v '^claude_logs/' || true)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | grep -v '^claude_logs/' || true)

if [ -z "$GIT_CHANGES" ] && [ -z "$STAGED_CHANGES" ] && [ -z "$UNTRACKED" ]; then
  # ファイル変更なし → ログ不要
  exit 0
fi

# claude_logs/ に直近10分以内に作成されたファイルがあるかチェック (macOS対応)
TEN_MIN_AGO=$(date -v-10M +%s 2>/dev/null || date -d '10 minutes ago' +%s)
RECENT_LOG_FOUND=false

if [ -d "$LOG_DIR" ]; then
  for f in "$LOG_DIR"/*.md; do
    [ -f "$f" ] || continue
    # macOS: stat -f %B (birth time), Linux: stat -c %W
    FILE_TIME=$(stat -f %B "$f" 2>/dev/null || stat -c %W "$f" 2>/dev/null || echo 0)
    if [ "$FILE_TIME" -ge "$TEN_MIN_AGO" ]; then
      RECENT_LOG_FOUND=true
      break
    fi
  done
fi

if [ "$RECENT_LOG_FOUND" = "true" ]; then
  exit 0
fi

# ログが存在しない → ブロック
jq -n '{
  decision: "block",
  reason: "claude_logs/ に作業ログが作成されていません。CLAUDE.md の指示に従い、claude_logs/YYYYMMDD_HHmm_<about>.md 形式で作業ログを作成してから終了してください。ログには、ユーザーのプロンプト、会話履歴(概要)、作業の理由、計画内容、作業の内容を含めてください。"
}'
