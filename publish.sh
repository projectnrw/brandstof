#!/bin/bash
set -e
cd /workspace/fuel-app
export GIT_TERMINAL_PROMPT=0
python3 build.py
git add -A index.html manifest.json *.png data.json build.py publish.sh
# Safety: abort if the Tankerkoenig API key (or any key-like string) would be published
K="${TANKERKOENIG_API_KEY:-}"
if [ -n "$K" ] && git diff --cached | grep -qF "$K"; then echo "ABORT: API key found in staged files"; git reset -q; exit 1; fi
if git diff --cached -- . ":!publish.sh" | grep -qiE "apikey=|tankerkoenig_api_key|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"; then echo "ABORT: key-like string in staged files"; git reset -q; exit 1; fi
if ! git diff --cached --quiet; then
  git commit -qm "Update data $(date '+%F %H:%M')"
  for i in 1 2 3; do
    if git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=30 push -q origin main; then echo pushed; exit 0; fi
    echo "push failed (try $i), rebasing on remote"
    git fetch -q origin main && git rebase -q -X ours origin/main || { git rebase --abort 2>/dev/null; git reset -q --soft origin/main; git commit -qm "Update data $(date '+%F %H:%M')"; }
    sleep 5
  done
  echo "push failed after 3 tries"; exit 1
else echo "no changes"; fi
