#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# Configure these locally
# -------------------------
REPO_URL="https://github.com/shadowdev2024-com/web2.git"
COMMIT_MSG="Add CYBERDUNE-CTF project files (wasm, pages, api, build scripts)"
# -------------------------

pwd
echo "Running from: $(pwd)"

# 1) تأكد من المكان
if [ ! -f "index.html" ] && [ ! -f "flag.html" ]; then
  echo "ما لقيت index.html أو flag.html فالمجلد الحالي. وقف وذهب للمجلد الصحيح."
  exit 1
fi

# 2) أنشئ .gitignore إذا ماكانش
if [ ! -f ".gitignore" ]; then
  cat > .gitignore <<'EOF'
node_modules/
.env
*.log
.DS_Store
module.wat
*.zip
EOF
  echo ".gitignore created."
else
  echo ".gitignore already exists."
fi

# 3) إذا node_modules متتبعة، نحيدها من الـ index (نخليها محليا)
if git ls-files --error-unmatch node_modules >/dev/null 2>&1; then
  echo "Removing node_modules from git index (kept locally)..."
  git rm -r --cached node_modules || true
fi

# 4) init git if needed and set remote
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Initializing new git repo..."
  git init
fi

# ensure remote exists and points to the repo
if git remote get-url origin >/dev/null 2>&1; then
  CURRENT_REMOTE="$(git remote get-url origin)"
  if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
    echo "Updating origin remote URL to $REPO_URL"
    git remote set-url origin "$REPO_URL"
  else
    echo "Remote origin already set to $REPO_URL"
  fi
else
  echo "Adding origin remote: $REPO_URL"
  git remote add origin "$REPO_URL"
fi

# 5) create vercel.json if missing (serves correct content-type for wasm)
if [ ! -f "vercel.json" ]; then
  cat > vercel.json <<'JSON'
{
  "headers": [
    {
      "source": "/(.*)\\.wasm",
      "headers": [
        {
          "key": "Content-Type",
          "value": "application/wasm"
        }
      ]
    }
  ]
}
JSON
  echo "vercel.json created."
else
  echo "vercel.json already exists."
fi

# 6) stage and commit
git add .
# if nothing to commit, skip commit
if git diff --cached --quiet; then
  echo "No staged changes to commit."
else
  git commit -m "$COMMIT_MSG"
  echo "Committed changes."
fi

# 7) fetch remote and rebase local commits on top of remote branch
# detect remote default branch
REMOTE_BRANCH="main"
if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
  REMOTE_BRANCH="main"
elif git ls-remote --exit-code --heads origin master >/dev/null 2>&1; then
  REMOTE_BRANCH="master"
fi
echo "Using remote branch: $REMOTE_BRANCH"

# fetch and rebase
echo "Fetching origin..."
git fetch origin "$REMOTE_BRANCH" || true

# If remote has branch, rebase; else, push new branch
if git ls-remote --exit-code --heads origin "$REMOTE_BRANCH" >/dev/null 2>&1; then
  echo "Rebasing onto origin/$REMOTE_BRANCH..."
  git pull --rebase origin "$REMOTE_BRANCH" || {
    echo "Rebase failed due to conflicts. Resolve conflicts, then run:"
    echo "  git add <files>"
    echo "  git rebase --continue"
    exit 1
  }
else
  echo "Remote branch $REMOTE_BRANCH does not exist yet - will push new branch."
fi

# 8) push (will prompt for username/password or use credential helper)
echo "Now pushing to origin/$REMOTE_BRANCH. Git will prompt for credentials if needed."
git push origin HEAD:"$REMOTE_BRANCH"

echo "Push completed. Visit: https://github.com/shadowdev2024-com/web2"
