#!/bin/bash
set -e
cd /workspace/fuel-app
python3 build.py
git add -A index.html manifest.json *.png data.json build.py publish.sh
# Safety: abort if the Tankerkoenig API key (or any key-like string) would be published
K="${TANKERKOENIG_API_KEY:-}"
if [ -n "$K" ] && git diff --cached | grep -qF "$K"; then echo "ABORT: API key found in staged files"; git reset -q; exit 1; fi
if git diff --cached -- . ":!publish.sh" | grep -qiE "apikey=|tankerkoenig_api_key|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"; then echo "ABORT: key-like string in staged files"; git reset -q; exit 1; fi
if ! git diff --cached --quiet; then git commit -qm "Update data $(date '+%F %H:%M')"; git push -q origin main; echo pushed; else echo "no changes"; fi
