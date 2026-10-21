#!/usr/bin/env bash
# Exercise 1: First Node Setup and Invoice Generation
#   - Confirm Alice is running and funded
#   - Create a 50,000 sat invoice "Coffee Payment", expiry 3600s
#   - Decode it and prove the node generated it
# Usage: bash scripts/exercise-01.sh   (run from the repo root)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RUN_DIR="$PWD/lab/records/exercise-01/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
LOG="$RUN_DIR/session.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Exercise 1: First Node Setup and Invoice Generation ==="

ALICE_DIR="$PWD/lab/nodes/alice"

echo "-- [1/5] getinfo (node operational?) --"
lightning-cli --lightning-dir="$ALICE_DIR" getinfo | tee "$RUN_DIR/getinfo.txt"

echo "-- [2/5] listfunds (on-chain wallet funded?) --"
lightning-cli --lightning-dir="$ALICE_DIR" listfunds | tee "$RUN_DIR/listfunds.txt"

echo "-- [3/5] invoice 50000000msat coffee-payment 'Coffee Payment' 3600 --"
lightning-cli --lightning-dir="$ALICE_DIR" \
  invoice 50000000msat coffee-payment "Coffee Payment" 3600 \
  | tee "$RUN_DIR/invoice.txt"
BOLT11=$(python3 -c 'import sys,json;print(json.load(sys.stdin)["bolt11"])' < "$RUN_DIR/invoice.txt")
echo "$BOLT11" > "$RUN_DIR/bolt11.txt"
echo "BOLT11: $BOLT11"

echo "-- [4/5] decodeinvoice --"
lightning-cli --lightning-dir="$ALICE_DIR" decodeinvoice "$BOLT11" \
  | tee "$RUN_DIR/decoded.txt"

echo "-- [5/5] listinvoices (proof the node generated it) --"
lightning-cli --lightning-dir="$ALICE_DIR" listinvoices \
  | tee "$RUN_DIR/listinvoices.txt"

echo
echo "=== Done. Outputs saved in $RUN_DIR ==="
echo "Next steps:"
echo "  1. Verify decodeinvoice: num_satoshis=50000, description='Coffee Payment', expiry=3600"
echo "  2. Verify listinvoices: label=coffee-payment, status=unpaid, payee=Alice's node id"
echo "  3. Fill Table 1 in templates/snapshot.md"
echo "  4. git add . && git commit -m \"Exercise 1: node funded and Coffee Payment invoice generated\""
