#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f .githooks/pre-commit ]]; then
  echo "Missing .githooks/pre-commit" >&2
  exit 1
fi

chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
echo "Enabled core.hooksPath=.githooks for $REPO_ROOT"
