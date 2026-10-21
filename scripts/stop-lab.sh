#!/usr/bin/env bash
# Stop all CLN nodes and bitcoind.
# Usage: bash scripts/stop-lab.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RPC_USER=clnrpc RPC_PASS=clrpcpass RPC_PORT=18443
BTC=(bitcoin-cli -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" -regtest)

for n in alice bob carol; do
  if lightning-cli --lightning-dir="$PWD/lab/nodes/$n" stop >/dev/null 2>&1; then
    echo "$n stopped"
  else
    echo "$n not running (or already stopped)"
  fi
done

if "${BTC[@]}" stop >/dev/null 2>&1; then
  echo "bitcoind stopped"
else
  echo "bitcoind not running (or already stopped)"
fi

echo "Lab stopped."
