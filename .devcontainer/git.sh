#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

USERNAME="JedEatSnax"
GPG_UID="134795258+JedEatSnax@users.noreply.github.com"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${NC}[${RED}ERROR${NC}]Workspace is not a Git repository"
    exit 1
fi

if [[ -z "${GH_TOKEN:-}" ]]; then
    echo -e "${NC}[${RED}ERROR${NC}] GH_TOKEN is missing or empty"
    exit 1
fi

SIGNING_KEY="$(
    gpg --list-secret-keys \
        --with-colons \
        --fingerprint \
        "$GPG_UID" |
    awk -F: '
        $1 == "sec" { is_secret = 1; next }
        is_secret && $1 == "fpr" {
            print $10
            exit
        }
    '
)"

if [[ -z "$SIGNING_KEY" ]]; then
    echo -e "${NC}[${RED}ERROR${NC}] No signing key found for $GPG_UID"
    exit 1
fi

git config --local user.name "$USERNAME"
git config --local user.email "$GPG_UID"
git config --local user.signingkey "$SIGNING_KEY"
git config --local commit.gpgsign true
git config --local gpg.program gpg

GITHUB_USER="$(gh api user --jq .login)"

if [[ "$GITHUB_USER" != "$USERNAME" ]]; then
    echo -e "${NC}[${RED}ERROR${NC}]Authenticated as unexpected GitHub user: $GITHUB_USER"
    exit 1
fi

echo -e "${NC}[${GREEN}INFO${NC}] Git identity configured: $USERNAME"
echo -e "${NC}[${GREEN}INFO${NC}] GPG signing key configured: $SIGNING_KEY"
echo -e "${NC}[${GREEN}INFO${NC}] GitHub CLI authenticated as: $GITHUB_USER"
