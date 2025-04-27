;; Usage Tracking Contract
;; Monitors consumption of licensed content

;; Usage record structure
(define-map usage-records
  { license-id: uint, user: principal }
  {
    asset-id: uint,
    access-count: uint,
    last-access: uint
  }
)

;; License structure
(define-map licenses
  { license-id: uint }
  {
    asset-id: uint,
    licensee: principal,
    template-id: uint,
    start-time: uint,
    end-time: uint,
    is-active: bool
  }
)

;; Track license count
(define-data-var license-count uint u0)

;; Error codes
(define-constant err-license-not-found (err u400))
(define-constant err-license-expired (err u401))
(define-constant err-not-licensee (err u402))

;; Create a new license
(define-public (create-license (asset-id uint) (template-id uint) (duration-days uint))
  (let (
    (license-id (var-get license-count))
    (start-time block-height)
    (end-time (+ block-height (* duration-days u144))) ;; Approx. 144 blocks per day
  )
    (map-set licenses
      { license-id: license-id }
      {
        asset-id: asset-id,
        licensee: tx-sender,
        template-id: template-id,
        start-time: start-time,
        end-time: end-time,
        is-active: true
      })
    (var-set license-count (+ license-id u1))
    (ok license-id)))

;; Record content usage
(define-public (record-usage (license-id uint))
  (let (
    (license (map-get? licenses { license-id: license-id }))
    (current-time block-height)
  )
    (asserts! (is-some license) err-license-not-found)
    (let ((license-data (unwrap-panic license)))
      (asserts! (is-eq (get licensee license-data) tx-sender) err-not-licensee)
      (asserts! (and (get is-active license-data) (<= current-time (get end-time license-data))) err-license-expired)

      (let ((existing-record (map-get? usage-records { license-id: license-id, user: tx-sender })))
        (if (is-some existing-record)
          (let ((record-data (unwrap-panic existing-record)))
            (map-set usage-records
              { license-id: license-id, user: tx-sender }
              {
                asset-id: (get asset-id license-data),
                access-count: (+ (get access-count record-data) u1),
                last-access: current-time
              }))
          (map-set usage-records
            { license-id: license-id, user: tx-sender }
            {
              asset-id: (get asset-id license-data),
              access-count: u1,
              last-access: current-time
            })))
      (ok true))))

;; Get license details
(define-read-only (get-license (license-id uint))
  (map-get? licenses { license-id: license-id }))

;; Get usage details
(define-read-only (get-usage (license-id uint) (user principal))
  (map-get? usage-records { license-id: license-id, user: user }))
