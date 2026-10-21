#!/usr/bin/env bash
# Exercise 3: Multi-Hop Payment Routing
#   - Connect Bob <-> Carol, open 300,000 sat channel
#   - Carol invoices 100,000 sat
#   - Alice pays via Bob (Alice -> Bob -> Carol)
# Usage: bash scripts/exercise-03.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RPC_USER=clnrpc RPC_PASS=clrpcpass RPC_PORT=18443
BTC=(bitcoin-cli -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" -regtest)

RUN_DIR="$PWD/lab/records/exercise-03/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
LOG="$RUN_DIR/session.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Exercise 3: Multi-Hop Payment Routing ==="
echo "Prerequisite: scripts/start-lab.sh and scripts/exercise-02.sh already ran"

ALICE_DIR="$PWD/lab/nodes/alice"
BOB_DIR="$PWD/lab/nodes/bob"
CAROL_DIR="$PWD/lab/nodes/carol"

echo "-- [1/4] Bob connects to Carol and opens 300,000 sat channel --"
CAROL_ID=$(lightning-cli --lightning-dir="$CAROL_DIR" getinfo | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
lightning-cli --lightning-dir="$BOB_DIR" connect "$CAROL_ID@127.0.0.1:9737" \
  | tee "$RUN_DIR/connect.txt"
lightning-cli --lightning-dir="$BOB_DIR" fundchannel "$CAROL_ID" 300000 \
  | tee "$RUN_DIR/fundchannel.txt"
"${BTC[@]}" generatetoaddress 6 $("${BTC[@]}" getnewaddress) >/dev/null
echo "6 blocks mined"

echo "-- [2/4] Verify Bob->Carol channel is CHANNELD_NORMAL --"
lightning-cli --lightning-dir="$BOB_DIR" listchannels   | tee "$RUN_DIR/listchannels-bob.txt"
lightning-cli --lightning-dir="$CAROL_DIR" listchannels | tee "$RUN_DIR/listchannels-carol.txt"

echo "-- [3/4] Carol creates 100,000 sat invoice --"
lightning-cli --lightning-dir="$CAROL_DIR" \
  invoice 100000000msat inv-ex3 "Payment from Alice via Bob" 3600 \
  | tee "$RUN_DIR/invoice-carol.txt"
BOLT11=$(python3 -c 'import sys,json;print(json.load(sys.stdin)["bolt11"])' < "$RUN_DIR/invoice-carol.txt")
echo "$BOLT11" > "$RUN_DIR/bolt11.txt"
echo "BOLT11: $BOLT11"

echo "-- [4/4] Alice pays (routes Alice -> Bob -> Carol) --"
lightning-cli --lightning-dir="$ALICE_DIR" pay "$BOLT11" \
  | tee "$RUN_DIR/pay-alice.txt"

echo "-- Verification --"
lightning-cli --lightning-dir="$ALICE_DIR" listpays      | tee "$RUN_DIR/listpays-alice.txt"
lightning-cli --lightning-dir="$CAROL_DIR" listinvoices  | tee "$RUN_DIR/listinvoices-carol.txt"
lightning-cli --lightning-dir="$ALICE_DIR" listchannels  | tee "$RUN_DIR/listchannels-alice-after.txt"
lightning-cli --lightning-dir="$BOB_DIR"  listchannels  | tee "$RUN_DIR/listchannels-bob-after.txt"
lightning-cli --lightning-dir="$CAROL_DIR" listchannels | tee "$RUN_DIR/listchannels-carol-after.txt"

echo
echo "=== Done. Outputs saved in $RUN_DIR ==="
echo "Next steps:"
echo "  1. listpays-alice.txt: status=complete, preimage present"
echo "  2. listinvoices-carol.txt: inv-ex3 status=paid"
echo "  3. Channels: alice->bob local -100,000 sat (-fee); bob->carol remote +100,000 sat (+fee)"
echo "  4. Fill Table 3 in templates/snapshot.md"
echo "  5. git add . && git commit -m \"Exercise 3: 100k sat payment routed Alice -> Bob -> Carol\""
