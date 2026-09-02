#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=/opt/oauth2-reference-server/repo
STATE_FILE=dev.env

cd "$REPO_DIR"

exec 9>"$REPO_DIR/../.deploy.lock"
flock -n 9 || { echo "Deploy läuft bereits"; exit 0; }

retry() {
    local n=0
    until "$@"; do
        n=$((n + 1))
        (( n >= 3 )) && return 1
        echo "Fehlgeschlagen, Versuch $((n + 1)) in $((n * 5))s: $*" >&2
        sleep $((n * 5))
    done
}

PREV=""
[[ -f .env ]] && PREV=$(cat .env)

retry git fetch --quiet origin main deploy
git reset --hard --quiet origin/main
git show "origin/deploy:$STATE_FILE" > .env

retry docker compose pull --quiet

if docker compose up -d --wait --wait-timeout 120; then
    echo "Aktuell: $(grep APP_IMAGE .env)"
    exit 0
fi

echo "Deploy fehlgeschlagen" >&2
if [[ -n "$PREV" && "$PREV" != "$(cat .env)" ]]; then
    echo "Rollback auf vorherigen Digest" >&2
    printf '%s\n' "$PREV" > .env
    docker compose up -d --wait --wait-timeout 120
fi
exit 1