#!/bin/bash
set -e
cd /workspace/fuel-app
python3 build.py
git add -A index.html manifest.json *.png data.json build.py publish.sh
if ! git diff --cached --quiet; then git commit -qm "Update data $(date '+%F %H:%M')"; git push -q origin main; echo pushed; else echo "no changes"; fi
