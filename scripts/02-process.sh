#!/bin/bash
set -e

REPOS_DIR=${1:-"data/raw/repos"}
RAW_DATA_DIR=${2:-"data/raw"}
SBOM_DIR="data/processed/sboms"

mkdir -p "$RAW_DATA_DIR"
mkdir -p "$SBOM_DIR"

if [ -z "$(ls -A "$REPOS_DIR" 2>/dev/null)" ]; then
    echo -e "\e[33mNo repositories found in $REPOS_DIR. Please run 01-extract.sh first.\e[0m"
    exit 1
fi

REPO_COUNT=$(find "$REPOS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | xargs)
echo -e "\e[36mStarting SBOM generation and vulnerability scanning for $REPO_COUNT repositories...\e[0m"

for REPO_PATH in "$REPOS_DIR"/*; do
    if [ ! -d "$REPO_PATH" ]; then
        continue
    fi
    
    REPO_NAME=$(basename "$REPO_PATH")
    SBOM_PATH="$SBOM_DIR/$REPO_NAME-sbom.json"
    VULN_PATH="$RAW_DATA_DIR/$REPO_NAME-vulns.json"

    echo -e "\e[33mProcessing repository: $REPO_NAME\e[0m"

    # Generate SBOM using syft
    echo -e "\e[32m  -> Generating SBOM...\e[0m"
    if ! syft packages "dir:$REPO_PATH" -o "json=$SBOM_PATH" -q; then
        echo -e "\e[31mFailed to run syft on $REPO_PATH\e[0m" >&2
        continue
    fi

    # Generate Vulnerability Report using grype
    echo -e "\e[32m  -> Scanning for vulnerabilities...\e[0m"
    if ! grype "sbom:$SBOM_PATH" -o json > "$VULN_PATH"; then
        echo -e "\e[31mFailed to run grype on $SBOM_PATH\e[0m" >&2
        continue
    fi
done

echo -e "\e[36mProcessing complete. Output files saved in $RAW_DATA_DIR and $SBOM_DIR.\e[0m"
