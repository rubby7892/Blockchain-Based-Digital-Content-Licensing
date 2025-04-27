;; Revenue Distribution Contract
;; Handles automated payments to creators

(define-data-var admin principal tx-sender)

;; Payment record structure
(define-map payment-records
  { payment-id: uint }
  {
    asset-id: uint,
    license-id: uint,
    amount: uint,
    creator: principal,
    licensee: principal,
    timestamp: uint,
    status: (string-ascii 20)
  }
)

;; Track payment count
(define-data-var payment-count uint u0)

;; Error codes
(define-constant err-insufficient-funds (err u500))
(define-constant err-payment-failed (err u501))
(define-constant err-not-admin (err u502))

;; Make a payment for a license
(define-public (make-payment (license-id uint) (asset-id uint) (creator principal) (amount uint))
  (let ((payment-id (var-get payment-count)))
    ;; Transfer STX from sender to creator
    (match (stx-transfer? amount tx-sender creator)
      success
        (begin
          (map-set payment-records
            { payment-id: payment-id }
            {
              asset-id: asset-id,
              license-id: license-id,
              amount: amount,
              creator: creator,
              licensee: tx-sender,
              timestamp: block-height,
              status: "completed"
            })
          (var-set payment-count (+ payment-id u1))
          (ok payment-id))
      error
        (begin
          (map-set payment-records
            { payment-id: payment-id }
            {
              asset-id: asset-id,
              license-id: license-id,
              amount: amount,
              creator: creator,
              licensee: tx-sender,
              timestamp: block-height,
              status: "failed"
            })
          (var-set payment-count (+ payment-id u1))
          err-payment-failed))))

;; Get payment details
(define-read-only (get-payment (payment-id uint))
  (map-get? payment-records { payment-id: payment-id }))

;; Set admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-not-admin)
    (ok (var-set admin new-admin))))
