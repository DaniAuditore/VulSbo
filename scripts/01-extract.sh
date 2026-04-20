#!/bin/bash
set -e

ORG=${1:-"OWASP"}
LIMIT=${2:-50}
TARGET_DIR="data/raw/repos"

mkdir -p "$TARGET_DIR"

# Calculate date 1 month ago (works on both GNU and BSD/macOS date)
ONE_MONTH_AGO=$(date -d "1 month ago" +%Y-%m-%d 2>/dev/null || date -v-1m +%Y-%m-%d)

echo -e "\e[36mFetching up to $LIMIT active repositories from $ORG updated since $ONE_MONTH_AGO...\e[0m"

# Fetch repos using GitHub CLI and filter by date using jq
# gh repo list requires authentication, make sure you are logged in or have GITHUB_TOKEN set.
REPOS=$(gh repo list "$ORG" --json nameWithOwner,pushedAt -L "$LIMIT" | \
    jq -r ".[] | select(.pushedAt >= \"$ONE_MONTH_AGO\") | .nameWithOwner")

if [ -z "$REPOS" ]; then
    echo -e "\e[33mNo active repositories found in the last month.\e[0m"
    exit 0
fi

REPO_COUNT=$(echo "$REPOS" | wc -w)
echo -e "\e[36mStarting extraction of $REPO_COUNT repositories...\e[0m"

for REPO in $REPOS; do
    REPO_NAME=$(basename "$REPO")
    REPO_PATH="$TARGET_DIR/$REPO_NAME"
    
    if [ -d "$REPO_PATH" ]; then
        echo -e "\e[33mRepository $REPO already exists at $REPO_PATH. Skipping clone.\e[0m"
        continue
    fi

    echo -e "\e[32mCloning $REPO into $REPO_PATH...\e[0m"
    gh repo clone "$REPO" "$REPO_PATH" || {
        echo -e "\e[31mFailed to clone $REPO\e[0m" >&2
    }
done

echo -e "\e[36mExtraction complete.\e[0m"
