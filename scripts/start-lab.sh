#!/usr/bin/env bash
# Start a local regtest Bitcoin + Core Lightning lab (alice, bob, carol).
# Usage: bash scripts/start-lab.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RPC_USER="clnrpc"
RPC_PASS="clrpcpass"
RPC_PORT="18443"
BTC=(bitcoin-cli -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" -regtest)

LAB_DIR="$PWD/lab"
NODES_DIR="$LAB_DIR/nodes"
RECORDS_DIR="$LAB_DIR/records"
mkdir -p "$NODES_DIR" "$RECORDS_DIR"

echo "== [start-lab] Checking bitcoind (regtest) =="
if ! "${BTC[@]}" getblockchaininfo >/dev/null 2>&1; then
  echo "Starting bitcoind..."
  bitcoind -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" \
    -rpcallowip=127.0.0.1 -wallet=lab -daemon
  for i in $(seq 1 30); do
    if "${BTC[@]}" getblockchaininfo >/dev/null 2>&1; then echo "bitcoind ready"; break; fi
    sleep 1
  done
  "${BTC[@]}" getblockchaininfo >/dev/null || { echo "ERROR: bitcoind did not start"; exit 1; }
else
  echo "bitcoind already running"
fi

declare -A PORTS=( [alice]=9735 [bob]=9736 [carol]=9737 )

start_node() {
  local n="$1" p="${PORTS[$1]}"
  local dir="$NODES_DIR/$n"
  mkdir -p "$dir"
  if lightning-cli --lightning-dir="$dir" getinfo >/dev/null 2>&1; then
    echo "$n already running"; return
  fi
  echo "Starting $n (port $p)..."
  lightningd --network=regtest \
    --bitcoin-rpcuser="$RPC_USER" --bitcoin-rpcpassword="$RPC_PASS" \
    --bitcoin-rpcport="$RPC_PORT" --bitcoin-rpcconnect=127.0.0.1 \
    --lightning-dir="$dir" --log-file="$dir/$n.log" \
    --port="$p" --binding=127.0.0.1 --announce-addr="127.0.0.1:$p" \
    --daemon
  for i in $(seq 1 15); do
    if lightning-cli --lightning-dir="$dir" getinfo >/dev/null 2>&1; then echo "$n ready"; return; fi
    sleep 1
  done
  echo "ERROR: $n failed to start; check $dir/$n.log"; exit 1
}

for n in alice bob carol; do start_node "$n"; done

echo "== [start-lab] Funding node on-chain wallets =="
for n in alice bob carol; do
  dir="$NODES_DIR/$n"
  ADDR=$(lightning-cli --lightning-dir="$dir" newaddr | python3 -c 'import sys,json;print(json.load(sys.stdin)["bech32"])')
  echo "$n deposit address: $ADDR"
  "${BTC[@]}" generatetoaddress 101 "$ADDR" >/dev/null
  echo "$n funded (101 blocks mined and matured)"
done

echo "== [start-lab] Node summary =="
for n in alice bob carol; do
  echo "--- $n ---"
  lightning-cli --lightning-dir="$NODES_DIR/$n" getinfo | python3 -c '
import sys, json
d = json.load(sys.stdin)
print("id:     ", d.get("id"))
print("alias:  ", d.get("alias"))
print("port:   ", d.get("binding", [{}])[0].get("port") if d.get("binding") else "?")
print("peers:  ", d.get("num_peers"))
print("block:  ", d.get("blockheight"))
'
done

echo
echo "Lab ready. Next: bash scripts/exercise-01.sh"
