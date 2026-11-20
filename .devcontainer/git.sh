#!/usr/bin/env bash
set -euo pipefail

USERNAME="JedEatSnax"

GPG_UID="134795258+JedEatSnax@users.noreply.github.com"

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
    echo "ERROR: No signing key found for $GPG_UID"
    exit 1
fi

git config --local user.name "$USERNAME"
git config --local user.email "$GPG_UID"
git config --local user.signingkey "$SIGNING_KEY"
git config --local commit.gpgsign true
git config --local gpg.program gpg

echo "Configured GPG signing key: $SIGNING_KEY"