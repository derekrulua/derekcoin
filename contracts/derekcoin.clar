;; title: derekcoin
;; version: 1.0.0
;; summary: A simple SIP-010-like fungible token for Derek Coin (DEREK)
;; description: Minimal fungible token with one-time initializer, transfers, and metadata accessors.

;; ============
;; Constants
;; ============
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-INITIALIZED u102)
(define-constant ERR-ZERO-TRANSFER u103)

(define-constant TOKEN-NAME "Derek Coin")
(define-constant TOKEN-SYMBOL "DEREK")
(define-constant TOKEN-DECIMALS u8) ;; 8 decimals like STX

;; ============
;; Data storage
;; ============
(define-data-var total-supply uint u0)
(define-data-var initialized bool false)

(define-map balances { account: principal } { balance: uint })

;; ============
;; Read-only functions (SIP-010-like)
;; ============
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-token-uri)
  (ok none)
)

(define-read-only (get-total-supply)
  (some (var-get total-supply))
)

(define-read-only (get-balance (who principal))
  (match (map-get? balances { account: who })
    balance-data (get balance balance-data)
    u0
  )
)

;; ============
;; Public functions
;; ============
;; One-time initializer to mint a fixed supply to a chosen recipient
(define-public (initialize (supply uint) (recipient principal))
  (if (var-get initialized)
      (err ERR-INITIALIZED)
      (begin
        (var-set total-supply supply)
        (map-set balances { account: recipient } { balance: supply })
        (var-set initialized true)
        (ok true)
      )
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if (not (> amount u0))
      (err ERR-ZERO-TRANSFER)
      (if (not (is-eq tx-sender sender))
          (err ERR-NOT-AUTHORIZED)
          (begin
            (try! (sub-balance sender amount))
            (add-balance recipient amount)
            (ok true)
          )
      )
  )
)

;; ============
;; Private helpers
;; ============
(define-private (sub-balance (who principal) (amount uint))
  (let ((current (get-balance who)))
    (if (>= current amount)
        (begin
          (map-set balances { account: who } { balance: (- current amount) })
          (ok true)
        )
        (err ERR-INSUFFICIENT-BALANCE)
    )
  )
)

(define-private (add-balance (who principal) (amount uint))
  (let ((current (get-balance who)))
    (begin
      (map-set balances { account: who } { balance: (+ current amount) })
      true
    )
  )
)
