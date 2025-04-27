;; Asset Registration Contract
;; Records details of digital works

(define-data-var admin principal tx-sender)

;; Asset structure
(define-map assets
  { asset-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    content-hash: (buff 32),
    creation-time: uint,
    is-active: bool
  }
)

;; Track asset count
(define-data-var asset-count uint u0)

;; Error codes
(define-constant err-not-creator (err u200))
(define-constant err-asset-not-found (err u201))
(define-constant err-asset-inactive (err u202))

;; Register a new asset
(define-public (register-asset
    (title (string-ascii 100))
    (description (string-ascii 500))
    (content-hash (buff 32)))
  (let ((asset-id (var-get asset-count)))
    (map-set assets
      { asset-id: asset-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        content-hash: content-hash,
        creation-time: block-height,
        is-active: true
      })
    (var-set asset-count (+ asset-id u1))
    (ok asset-id)))

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id }))

;; Deactivate an asset
(define-public (deactivate-asset (asset-id uint))
  (let ((asset (map-get? assets { asset-id: asset-id })))
    (asserts! (is-some asset) err-asset-not-found)
    (asserts! (is-eq (get creator (unwrap-panic asset)) tx-sender) err-not-creator)
    (map-set assets
      { asset-id: asset-id }
      (merge (unwrap-panic asset) { is-active: false }))
    (ok true)))

;; Reactivate an asset
(define-public (reactivate-asset (asset-id uint))
  (let ((asset (map-get? assets { asset-id: asset-id })))
    (asserts! (is-some asset) err-asset-not-found)
    (asserts! (is-eq (get creator (unwrap-panic asset)) tx-sender) err-not-creator)
    (map-set assets
      { asset-id: asset-id }
      (merge (unwrap-panic asset) { is-active: true }))
    (ok true)))
