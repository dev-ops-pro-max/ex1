#!/usr/bin/env bash
# Exercise 2: Peer Connection and Channel Establishment
#   - Connect Alice <-> Bob
#   - Alice opens a 500,000 sat channel to Bob
#   - Verify CHANNELD_NORMAL on both nodes
# Usage: bash scripts/exercise-02.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RPC_USER=clnrpc RPC_PASS=clrpcpass RPC_PORT=18443
BTC=(bitcoin-cli -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" -regtest)

RUN_DIR="$PWD/lab/records/exercise-02/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
LOG="$RUN_DIR/session.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Exercise 2: Peer Connection and Channel Establishment ==="
echo "Prerequisite: run scripts/start-lab.sh first"

ALICE_DIR="$PWD/lab/nodes/alice"
BOB_DIR="$PWD/lab/nodes/bob"

echo "-- [1/4] Node IDs --"
ALICE_ID=$(lightning-cli --lightning-dir="$ALICE_DIR" getinfo | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
BOB_ID=$(lightning-cli --lightning-dir="$BOB_DIR" getinfo | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "Alice: $ALICE_ID"
echo "Bob:   $BOB_ID"

echo "-- [2/4] Alice connects to Bob --"
lightning-cli --lightning-dir="$ALICE_DIR" connect "$BOB_ID@127.0.0.1:9736" \
  | tee "$RUN_DIR/connect.txt"

echo "-- [3/4] Alice opens 500,000 sat channel to Bob --"
lightning-cli --lightning-dir="$ALICE_DIR" fundchannel "$BOB_ID" 500000 \
  | tee "$RUN_DIR/fundchannel.txt"

echo "-- Funding transaction confirmations (6 blocks) --"
"${BTC[@]}" generatetoaddress 6 $("${BTC[@]}" getnewaddress) >/dev/null
echo "6 blocks mined"

echo "-- [4/4] Verify channel and peers on both nodes --"
lightning-cli --lightning-dir="$ALICE_DIR" listchannels   | tee "$RUN_DIR/listchannels-alice.txt"
lightning-cli --lightning-dir="$BOB_DIR"  listchannels   | tee "$RUN_DIR/listchannels-bob.txt"
lightning-cli --lightning-dir="$ALICE_DIR" listpeers     | tee "$RUN_DIR/listpeers-alice.txt"
lightning-cli --lightning-dir="$BOB_DIR"  listpeers     | tee "$RUN_DIR/listpeers-bob.txt"

echo
echo "=== Done. Outputs saved in $RUN_DIR ==="
echo "Next steps:"
echo "  1. listpeers: Bob appears on Alice (and Alice on Bob)"
echo "  2. listchannels: state == CHANNELD_NORMAL, amount_msat == 500000000msat"
echo "  3. Fill Table 2 in templates/snapshot.md"
echo "  4. git add . && git commit -m \"Exercise 2: Alice-Bob peer connection and 500k channel established\""
