# DerekCoin

A minimal SIP-010-like fungible token implemented in Clarity using Clarinet. DerekCoin (symbol: `DEREK`) provides basic metadata, one-time initialization to mint a fixed supply, and token transfers.

## Features
- SIP-010-like metadata: name, symbol, decimals, optional token URI
- One-time initializer to set total supply and assign it to a recipient
- Safe transfers with balance checks and explicit error codes

## Contract
- Path: `contracts/derekcoin.clar`
- Name: `derekcoin`

Public entry points:
- `initialize (supply uint) (recipient principal) -> (response bool uint)`
- `transfer (amount uint) (sender principal) (recipient principal) -> (response bool uint)`

Read-only:
- `get-name () -> (response (string-ascii 32) uint)`
- `get-symbol () -> (response (string-ascii 32) uint)`
- `get-decimals () -> (response uint uint)`
- `get-token-uri () -> (response (optional (string-utf8 256)) uint)`
- `get-total-supply () -> (optional uint)`
- `get-balance (who principal) -> uint`

Error codes:
- `u100` not authorized
- `u101` insufficient balance
- `u102` already initialized
- `u103` zero-amount transfer

## Prerequisites
- Clarinet (v3+)
- Node.js and npm (for running tests)

Verify tools:
```bash
clarinet --version
node -v
npm -v
```

## Setup
Install deps (for tests) and check the project:
```bash
npm install
clarinet check
```

## Usage (Local Simnet)
Open the Clarinet console:
```bash
clarinet console
```
Then, in the REPL, initialize the token once with a fixed supply and recipient:
```clarity
(contract-call? .derekcoin initialize u100000000 '<RECIPIENT-PRINCIPAL>)
```
- Replace `<RECIPIENT-PRINCIPAL>` with a valid principal (e.g., one of the simnet wallets).
- Re-running `initialize` will fail with `u102`.

Transfer tokens (sender must be the transaction sender):
```clarity
(contract-call? .derekcoin transfer u1000 '<SENDER-PRINCIPAL> '<RECIPIENT-PRINCIPAL>)
```

Read data:
```clarity
(contract-call? .derekcoin get-name)
(contract-call? .derekcoin get-symbol)
(contract-call? .derekcoin get-decimals)
(contract-call? .derekcoin get-total-supply)
(contract-call? .derekcoin get-balance '<PRINCIPAL>)
```

## Testing
Run unit tests (Vitest + clarinet-js):
```bash
npm test
```

## Development
- `clarinet check` — static analysis and type checking
- `clarinet console` — interactive local chain for calling functions
- `clarinet contract new <name>` — scaffold new contracts

## Notes
- This contract is intentionally minimal and demonstrates core SIP-010-like behaviors without allowances/approvals.
- For production, consider implementing the full SIP-010 trait and permissions for minting/burning.
