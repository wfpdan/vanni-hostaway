#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
TOKEN_URL="https://accounts.zoho.com/oauth/v2/token"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Create it with Zoho credentials first." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to parse Zoho responses. Install jq and retry." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

for var in ZOHO_REFRESH_TOKEN ZOHO_CLIENT_ID ZOHO_CLIENT_SECRET; do
  if [ -z "${!var:-}" ]; then
    echo "Error: $var is missing from $ENV_FILE" >&2
    exit 1
  fi
done

echo "Requesting new Zoho access token..."
response="$(curl -sS --fail \
  --request POST "$TOKEN_URL" \
  --data-urlencode "refresh_token=$ZOHO_REFRESH_TOKEN" \
  --data-urlencode "client_id=$ZOHO_CLIENT_ID" \
  --data-urlencode "client_secret=$ZOHO_CLIENT_SECRET" \
  --data-urlencode "grant_type=refresh_token")"

new_access_token="$(echo "$response" | jq -r '.access_token // empty')"
expires_in="$(echo "$response" | jq -r '.expires_in // empty')"

if [ -z "$new_access_token" ]; then
  echo "Zoho token refresh failed. Raw response:" >&2
  echo "$response" >&2
  exit 1
fi

ENV_FILE="$ENV_FILE" NEW_TOKEN="$new_access_token" python3 <<'PY'
import os
from pathlib import Path

env_path = Path(os.environ["ENV_FILE"])
new_token = os.environ["NEW_TOKEN"]
lines = env_path.read_text().splitlines()
key = "ZOHO_ACCESS_TOKEN="
found = False
updated = []
for line in lines:
    if line.startswith(key):
        updated.append(f"{key}{new_token}")
        found = True
    else:
        updated.append(line)
if not found:
    updated.append(f"{key}{new_token}")
env_path.write_text("\n".join(updated) + "\n")
PY

echo "Updated ZOHO_ACCESS_TOKEN in $ENV_FILE"
if [ -n "$expires_in" ] && [ "$expires_in" != "null" ]; then
  echo "New token expires in ${expires_in} seconds."
fi
