;; License Template Contract
;; Manages standardized usage agreements

(define-data-var admin principal tx-sender)

;; License template structure
(define-map license-templates
  { template-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    duration-days: uint,
    commercial-use: bool,
    modification-allowed: bool,
    attribution-required: bool,
    fee: uint
  }
)

;; Track template count
(define-data-var template-count uint u0)

;; Error codes
(define-constant err-not-admin (err u300))
(define-constant err-template-not-found (err u301))

;; Create a new license template
(define-public (create-template
    (name (string-ascii 100))
    (description (string-ascii 500))
    (duration-days uint)
    (commercial-use bool)
    (modification-allowed bool)
    (attribution-required bool)
    (fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-not-admin)
    (let ((template-id (var-get template-count)))
      (map-set license-templates
        { template-id: template-id }
        {
          name: name,
          description: description,
          duration-days: duration-days,
          commercial-use: commercial-use,
          modification-allowed: modification-allowed,
          attribution-required: attribution-required,
          fee: fee
        })
      (var-set template-count (+ template-id u1))
      (ok template-id))))

;; Get template details
(define-read-only (get-template (template-id uint))
  (map-get? license-templates { template-id: template-id }))

;; Update a template
(define-public (update-template
    (template-id uint)
    (name (string-ascii 100))
    (description (string-ascii 500))
    (duration-days uint)
    (commercial-use bool)
    (modification-allowed bool)
    (attribution-required bool)
    (fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-not-admin)
    (asserts! (is-some (map-get? license-templates { template-id: template-id })) err-template-not-found)
    (map-set license-templates
      { template-id: template-id }
      {
        name: name,
        description: description,
        duration-days: duration-days,
        commercial-use: commercial-use,
        modification-allowed: modification-allowed,
        attribution-required: attribution-required,
        fee: fee
      })
    (ok true)))
