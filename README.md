# Core Lightning (CLN) — Four Lightning Network Exercises

This repository holds my work for four C-Lightning (Core Lightning) exercises:

1. **Exercise 1** — First node setup, wallet funding, BOLT11 invoice generation
2. **Exercise 2** — Peer connection and channel establishment (Alice ↔ Bob)
3. **Exercise 3** — Multi-hop payment routing (Alice → Bob → Carol)
4. **Exercise 4** — Circular rebalancing (Alice → Bob → Carol → Alice)

## What is in this repo

| Path | Purpose |
|------|---------|
| `docs/exercise-guide.md` | Step-by-step manual guide you work through, exercise by exercise |
| `scripts/start-lab.sh` | Starts a local regtest `bitcoind` + 3 CLN nodes (alice, bob, carol) and funds them |
| `scripts/exercise-0{1,2,3,4}.sh` | Runs the CLI commands for each exercise and saves output to `records/` |
| `scripts/stop-lab.sh` | Stops all nodes and bitcoind |
| `templates/snapshot.md` | Fill-in tables for before/after channel balance snapshots |
| `records/` | Captured command output (invoices, decodes, channel lists, preimages) — commit these |

## How to use

1. Work through `docs/exercise-guide.md`. Run one exercise script at a time, on your own machine.
2. After each exercise, fill in the matching table in `templates/snapshot.md` and save any proof files (invoice, decoded invoice, preimage) under `records/exercise-N/`.
3. Commit after each exercise:

   ```bash
   git add .
   git commit -m "Exercise 1: invoice generated and verified"
   ```

## Environment requirements

- **Bitcoin Core**: `bitcoind`, `bitcoin-cli`
- **Core Lightning**: `lightningd`, `lightning-cli`
- **python3** (used by helper scripts for JSON parsing)
- **bash** (Linux, macOS, or WSL2 on Windows)

**Windows note:** `lightningd` is Linux-native and is not officially supported on
Windows. Use **WSL2 (Ubuntu)** and run the bash scripts there. You can install
Bitcoin Core and Core Lightning inside WSL with the normal package instructions.

This environment does not have `bitcoind` or `lightningd` installed, so the lab
must be run on your machine — the scripts and guide below are what you execute
manually, step by step.
