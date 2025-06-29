;; Idea Forge-Guardian

(define-data-var asset-counter-sequence uint u0)
(define-constant SYSTEM_ADMINISTRATOR tx-sender)
(define-constant ERROR_PERMISSION_DENIED (err u300))
(define-constant ERROR_ASSET_NOT_FOUND (err u301))
(define-constant ERROR_DUPLICATE_ASSET_ENTRY (err u302))
(define-constant ERROR_INVALID_ASSET_DESIGNATION (err u303))
(define-constant ERROR_INVALID_CONTENT_SIZE (err u304))
(define-constant ERROR_ACCESS_DENIED (err u305))

