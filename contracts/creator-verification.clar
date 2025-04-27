;; Creator Verification Contract
;; This contract validates legitimate content producers

(define-data-var admin principal tx-sender)

;; Map to store verified creators
(define-map verified-creators principal bool)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Verify a creator
(define-public (verify-creator (creator principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? verified-creators creator)) err-already-verified)
    (ok (map-set verified-creators creator true))))

;; Revoke verification
(define-public (revoke-verification (creator principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? verified-creators creator)) err-not-verified)
    (ok (map-delete verified-creators creator))))

;; Check if a creator is verified
(define-read-only (is-verified (creator principal))
  (default-to false (map-get? verified-creators creator)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
