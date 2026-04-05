#!/usr/bin/env bash
set -euo pipefail

SURGE_CLI_BIN="${SURGE_CLI_BIN:-/Applications/Surge.app/Contents/Applications/surge-cli}"
PROFILE_PATH="${1:-dist/Full.conf}"

if [[ ! -x "$SURGE_CLI_BIN" ]]; then
  echo "surge-cli 不存在或不可执行: $SURGE_CLI_BIN" >&2
  exit 1
fi

if [[ ! -f "$PROFILE_PATH" ]]; then
  echo "待校验配置不存在: $PROFILE_PATH" >&2
  exit 1
fi

"$SURGE_CLI_BIN" --check "$PROFILE_PATH"
