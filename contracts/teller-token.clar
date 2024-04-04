
;; title: teller-token
;; version: 0.22
;; summary: Teller Token for CLI
;; description:


(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant ERR_FAILED_TO_TRANSFER_TO_DEVELOPER_WALLET (err u102))
(define-constant DEVELOPER_WALLET 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ)

;; No maximum supply!
(define-fungible-token teller-token)

(define-private (send-stx (recipient { to: principal, amount: uint }))
  (ft-transfer? teller-token (get amount recipient) tx-sender (get to recipient)))

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))

(define-read-only (get-name)
	(ok "Teller Token")
)

(define-read-only (get-symbol)
	(ok "TELLER")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance teller-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply teller-token))
)

(define-read-only (get-token-uri)
	(ok none)
)

(define-public (command_burn_metrics (amount uint))
  (let (
    (totalBurn (/ (* amount u4) u100))
    (metricsBurn (/ totalBurn u2))
    (developerAmount (* metricsBurn u10))
  )
    (begin
      (try! (ft-burn? teller-token metricsBurn tx-sender))
      (asserts! (unwrap-panic (ft-transfer? teller-token developerAmount tx-sender DEVELOPER_WALLET))
                ERR_FAILED_TO_TRANSFER_TO_DEVELOPER_WALLET)
      (ok true)
    )
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
    (try! (command_burn_metrics amount))
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(try! (ft-transfer? teller-token amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(ft-mint? teller-token amount recipient)
	)
)