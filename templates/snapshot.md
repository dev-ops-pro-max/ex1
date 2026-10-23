# Channel Balance Snapshots

Fill in one table per exercise as you go. Amounts in satoshis (msat / 1000).
`local`/`remote` are from the perspective of the node listed.

## Table 1 — Exercise 1 (invoice)

| Item | Value |
|------|-------|
| Node alias / id | YELLOWWATER |
| On-chain funds (listfunds, sat) | 50000 (regtest, blockheight 101) |
| Invoice label | coffee-payment |
| Amount (sat) | 50000 |
| Description | Coffee Payment |
| Expiry (s) | 3600 |
| BOLT11 | lnbcrt500u1p4d3pkvsp55x944c0yasfewh7xyuapk4hp05l2zncqk8cyeyj8xjhq6ryceg9spp5pq5xfttc5jsugncgdaguu9m37lsga7ym548tyq5rl9tuzarzvptqdqhgdhkven9v5s9qcted4jkuaqcqp29qxpqysgqxmqxs56x3vwhe2yfnact48um6f5d8aag24s3uy4vksr3dak86l2nsggl7x7fgqr64aqwec0ptkv9h67nj8a46c5e9ll2vkmwc5espsgp73pl2m |
| decodeinvoice verified? | ✓ |
| listinvoices shows status=unpaid, payee=self? | ✓ |

## Table 2 — Exercise 2 (Alice → Bob channel)

| Node | Channel id | Capacity (sat) | Local bal (sat) | Remote bal (sat) | State |
|------|------------|----------------|-----------------|------------------|-------|
| Alice | ch_2a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0aaa | 500000 | 500000 | 0 | CHANNELD_NORMAL |
| Bob | ch_2a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0aab | 500000 | 0 | 500000 | CHANNELD_NORMAL |

Peer check: Alice lists Bob? [✓]   Bob lists Alice? [✓]

## Table 3 — Exercise 3 (multi-hop payment)

Channel balances before payment:

| Channel | Alice local (sat) | Bob local (sat) | Carol local (sat) | State |
|---------|-------------------|-----------------|-------------------|-------|
| Alice→Bob | 400000 | 100000 | — | CHANNELD_NORMAL |
| Bob→Carol | — | 300000 | 200000 | CHANNELD_NORMAL |

Invoice: inv-ex3, 100,000 sat, payee = Carol

| Item | Value |
|------|-------|
| Payment status (Alice listpays) | complete |
| Preimage received? | [ ] |
| Invoice paid (Carol listinvoices)? | [ ] |
| Alice→Bob: Alice local change | -100,000 (-fee) |
| Bob→Carol: Bob local change, fee collected | -100,000 (-fee) |

## Table 4 — Exercise 4 (circular rebalance)

Setup: Alice→Bob (Alice funded), Bob→Carol (Bob funded), Carol→Alice (Carol funded)

| Channel | Local bal BEFORE (sat) | Local bal AFTER (sat) | Change (sat) |
|---------|------------------------|-----------------------|--------------|
| Alice→Bob (Alice side) | 500000 | 350000 | ≈ -150,000 |
| Bob→Carol (Bob side) | 500000 | 350000 | ≈ -150,000 (-fee) |
| Carol→Alice (Carol side) | 500000 | 350000 | ≈ -150,000 |
| Carol→Alice (Alice remote side) | 0 | 150000 | ≈ +150,000 |

| Item | Value |
|------|-------|
| Payment status (Alice listpays) | complete |
| Preimage received? | [ ] |
| Invoice inv-ex4 paid (Carol)? | [ ] |
| All 3 channels CHANNELD_NORMAL? | [ ] |

Notes (routing fees observed, anything unexpected):
