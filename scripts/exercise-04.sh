#!/usr/bin/env bash
# Exercise 4: Circular Rebalancing
#   - Carol opens 400,000 sat channel to Alice (completes the circle)
#   - Record BEFORE balances
#   - Carol invoices Alice 150,000 sat
#   - Alice pays herself via Alice -> Bob -> Carol -> Alice
#   - Record AFTER balances and compare
# Usage: bash scripts/exercise-04.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RPC_USER=clnrpc RPC_PASS=clrpcpass RPC_PORT=18443
BTC=(bitcoin-cli -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcport="$RPC_PORT" -regtest)

RUN_DIR="$PWD/lab/records/exercise-04/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
LOG="$RUN_DIR/session.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Exercise 4: Circular Rebalancing ==="
echo "Prerequisite: scripts/exercise-03.sh already ran (Alice->Bob and Bob->Carol channels exist)"

ALICE_DIR="$PWD/lab/nodes/alice"
BOB_DIR="$PWD/lab/nodes/bob"
CAROL_DIR="$PWD/lab/nodes/carol"

ALICE_ID=$(lightning-cli --lightning-dir="$ALICE_DIR" getinfo | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')

echo "-- [1/5] Carol opens 400,000 sat channel to Alice --"
lightning-cli --lightning-dir="$CAROL_DIR" fundchannel "$ALICE_ID" 400000 \
  | tee "$RUN_DIR/fundchannel.txt"
"${BTC[@]}" generatetoaddress 6 $("${BTC[@]}" getnewaddress) >/dev/null
echo "6 blocks mined"

echo "-- [2/5] Verify all three channels are CHANNELD_NORMAL --"
lightning-cli --lightning-dir="$ALICE_DIR"   listchannels | tee "$RUN_DIR/listchannels-alice.txt"
lightning-cli --lightning-dir="$BOB_DIR"     listchannels | tee "$RUN_DIR/listchannels-bob.txt"
lightning-cli --lightning-dir="$CAROL_DIR"   listchannels | tee "$RUN_DIR/listchannels-carol.txt"

echo "-- [3/5] BEFORE snapshot (raw listchannels saved) --"
cp "$RUN_DIR/listchannels-alice.txt"  "$RUN_DIR/before-alice.txt"
cp "$RUN_DIR/listchannels-bob.txt"    "$RUN_DIR/before-bob.txt"
cp "$RUN_DIR/listchannels-carol.txt"  "$RUN_DIR/before-carol.txt"
echo "Before snapshots: $RUN_DIR/before-*.txt"

echo "-- [4/5] Carol invoices Alice 150,000 sat (payee = Alice) --"
lightning-cli --lightning-dir="$CAROL_DIR" \
  invoice 150000000msat inv-ex4 "Circular rebalance Alice via Bob Carol" 3600 \
  | tee "$RUN_DIR/invoice-carol.txt"
BOLT11=$(python3 -c 'import sys,json;print(json.load(sys.stdin)["bolt11"])' < "$RUN_DIR/invoice-carol.txt")
echo "$BOLT11" > "$RUN_DIR/bolt11.txt"
echo "BOLT11: $BOLT11"

echo "-- [5/5] Alice pays herself via the circle --"
lightning-cli --lightning-dir="$ALICE_DIR" pay "$BOLT11" \
  | tee "$RUN_DIR/pay-alice.txt"

echo "-- After snapshot --"
lightning-cli --lightning-dir="$ALICE_DIR"   listchannels | tee "$RUN_DIR/listchannels-alice-after.txt"
lightning-cli --lightning-dir="$BOB_DIR"     listchannels | tee "$RUN_DIR/listchannels-bob-after.txt"
lightning-cli --lightning-dir="$CAROL_DIR"   listchannels | tee "$RUN_DIR/listchannels-carol-after.txt"
cp "$RUN_DIR/listchannels-alice-after.txt" "$RUN_DIR/after-alice.txt"
cp "$RUN_DIR/listchannels-bob-after.txt"   "$RUN_DIR/after-bob.txt"
cp "$RUN_DIR/listchannels-carol-after.txt" "$RUN_DIR/after-carol.txt"

echo "-- Proof of payment --"
lightning-cli --lightning-dir="$ALICE_DIR" listpays     | tee "$RUN_DIR/listpays-alice.txt"
lightning-cli --lightning-dir="$CAROL_DIR" listinvoices | tee "$RUN_DIR/listinvoices-carol.txt"

echo
echo "=== Done. Outputs saved in $RUN_DIR ==="
echo "Next steps:"
echo "  1. listpays-alice.txt: status=complete, preimage present"
echo "  2. listinvoices-carol.txt: inv-ex4 status=paid"
echo "  3. Compare before/after balances in before-*.txt vs after-*.txt"
echo "     Expected: alice->bob Alice local -150,000 sat; carol->alice Alice remote +150,000 sat"
echo "  4. Fill Table 4 in templates/snapshot.md"
echo "  5. git add . && git commit -m \"Exercise 4: circular rebalance 150k sat Alice -> Bob -> Carol -> Alice\""
