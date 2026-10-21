# Channel Balance Snapshots

Fill in one table per exercise as you go. Amounts in satoshis (msat / 1000).
`local`/`remote` are from the perspective of the node listed.

## Table 1 — Exercise 1 (invoice)

| Item | Value |
|------|-------|
| Node alias / id | |
| On-chain funds (listfunds, sat) | |
| Invoice label | coffee-payment |
| Amount (sat) | 50000 |
| Description | Coffee Payment |
| Expiry (s) | 3600 |
| BOLT11 | (paste from records/exercise-01/run-*/bolt11.txt) |
| decodeinvoice verified? | [ ] |
| listinvoices shows status=unpaid, payee=self? | [ ] |

## Table 2 — Exercise 2 (Alice → Bob channel)

| Node | Channel id | Capacity (sat) | Local bal (sat) | Remote bal (sat) | State |
|------|------------|----------------|-----------------|------------------|-------|
| Alice | | 500000 | | | CHANNELD_NORMAL |
| Bob | | 500000 | | | CHANNELD_NORMAL |

Peer check: Alice lists Bob? [ ]   Bob lists Alice? [ ]

## Table 3 — Exercise 3 (multi-hop payment)

Channel balances before payment:

| Channel | Alice local (sat) | Bob local (sat) | Carol local (sat) | State |
|---------|-------------------|-----------------|-------------------|-------|
| Alice→Bob | | | | |
| Bob→Carol | | | | |

Invoice: inv-ex3, 100,000 sat, payee = Carol

| Item | Value |
|------|-------|
| Payment status (Alice listpays) | complete |
| Preimage received? | [ ] |
| Invoice paid (Carol listinvoices)? | [ ] |
| Alice→Bob: Alice local change | -100,000 (-fee) |
| Bob→Carol: Bob local change, fee collected | |

## Table 4 — Exercise 4 (circular rebalance)

Setup: Alice→Bob (Alice funded), Bob→Carol (Bob funded), Carol→Alice (Carol funded)

| Channel | Local bal BEFORE (sat) | Local bal AFTER (sat) | Change (sat) |
|---------|------------------------|-----------------------|--------------|
| Alice→Bob (Alice side) | | | ≈ -150,000 |
| Bob→Carol (Bob side) | | | ≈ -150,000 (-fee) |
| Carol→Alice (Carol side) | | | ≈ -150,000 |
| Carol→Alice (Alice remote side) | | | ≈ +150,000 |

| Item | Value |
|------|-------|
| Payment status (Alice listpays) | complete |
| Preimage received? | [ ] |
| Invoice inv-ex4 paid (Carol)? | [ ] |
| All 3 channels CHANNELD_NORMAL? | [ ] |

Notes (routing fees observed, anything unexpected):
