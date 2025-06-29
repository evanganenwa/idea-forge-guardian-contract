;; Idea Forge-Guardian

(define-data-var asset-counter-sequence uint u0)
(define-constant SYSTEM_ADMINISTRATOR tx-sender)
(define-constant ERROR_PERMISSION_DENIED (err u300))
(define-constant ERROR_ASSET_NOT_FOUND (err u301))
(define-constant ERROR_DUPLICATE_ASSET_ENTRY (err u302))
(define-constant ERROR_INVALID_ASSET_DESIGNATION (err u303))
(define-constant ERROR_INVALID_CONTENT_SIZE (err u304))
(define-constant ERROR_ACCESS_DENIED (err u305))


(define-map cognitive-asset-registry
  { asset-identifier: uint }
  {
    asset-designation: (string-ascii 80),
    proprietor-address: principal,
    content-magnitude: uint,
    inception-block: uint,
    descriptive-summary: (string-ascii 256),
    classification-tags: (list 8 (string-ascii 40))
  }
)

(define-map access-privilege-matrix
  { asset-identifier: uint, requesting-entity: principal }
  { viewing-permission: bool }
)


;; --------------------------------------------------------------------------
;; Asset Lifecycle Management Functions
;; --------------------------------------------------------------------------
(define-public (establish-cognitive-asset 
                (designation (string-ascii 80)) 
                (magnitude uint) 
                (summary (string-ascii 256)) 
                (tags (list 8 (string-ascii 40))))
  (let
    (
      (new-asset-id (+ (var-get asset-counter-sequence) u1))
    )
    ;; Parameter validation protocols
    (asserts! (> (len designation) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len designation) u81) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (> magnitude u0) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (< magnitude u2000000000) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (> (len summary) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len summary) u257) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (validate-classification-structure tags) ERROR_INVALID_ASSET_DESIGNATION)

    ;; Asset registration into cognitive registry
    (map-insert cognitive-asset-registry
      { asset-identifier: new-asset-id }
      {
        asset-designation: designation,
        proprietor-address: tx-sender,
        content-magnitude: magnitude,
        inception-block: block-height,
        descriptive-summary: summary,
        classification-tags: tags
      }
    )

    ;; Establish foundational access privileges for creator
    (map-insert access-privilege-matrix
      { asset-identifier: new-asset-id, requesting-entity: tx-sender }
      { viewing-permission: true }
    )
    
    ;; Increment system counter and return unique identifier
    (var-set asset-counter-sequence new-asset-id)
    (ok new-asset-id)
  )
)

;; Enhanced asset establishment with improved error handling
(define-public (create-enhanced-cognitive-entry 
                (designation (string-ascii 80)) 
                (magnitude uint) 
                (summary (string-ascii 256)) 
                (tags (list 8 (string-ascii 40))))
  (let
    (
      (generated-asset-id (+ (var-get asset-counter-sequence) u1))
    )
    ;; Comprehensive input validation sequence
    (asserts! (> (len designation) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len designation) u81) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (> magnitude u0) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (< magnitude u2000000000) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (> (len summary) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len summary) u257) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (validate-classification-structure tags) ERROR_INVALID_ASSET_DESIGNATION)

    ;; Cognitive asset metadata persistence
    (map-insert cognitive-asset-registry
      { asset-identifier: generated-asset-id }
      {
        asset-designation: designation,
        proprietor-address: tx-sender,
        content-magnitude: magnitude,
        inception-block: block-height,
        descriptive-summary: summary,
        classification-tags: tags
      }
    )

    ;; Proprietor access rights initialization
    (map-insert access-privilege-matrix
      { asset-identifier: generated-asset-id, requesting-entity: tx-sender }
      { viewing-permission: true }
    )
    
    ;; System state update and successful response
    (var-set asset-counter-sequence generated-asset-id)
    (ok generated-asset-id)
  )
)

;; --------------------------------------------------------------------------
;; Asset Modification and Maintenance Functions
;; --------------------------------------------------------------------------
(define-public (modify-asset-metadata 
                (asset-identifier uint) 
                (updated-designation (string-ascii 80)) 
                (updated-magnitude uint) 
                (updated-summary (string-ascii 256)) 
                (updated-tags (list 8 (string-ascii 40))))
  (let
    (
      (current-asset-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Asset existence and ownership verification
    (asserts! (verify-asset-existence asset-identifier) ERROR_ASSET_NOT_FOUND)
    (asserts! (is-eq (get proprietor-address current-asset-data) tx-sender) ERROR_ACCESS_DENIED)

    ;; Updated metadata validation protocols
    (asserts! (> (len updated-designation) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len updated-designation) u81) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (> updated-magnitude u0) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (< updated-magnitude u2000000000) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (> (len updated-summary) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len updated-summary) u257) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (validate-classification-structure updated-tags) ERROR_INVALID_ASSET_DESIGNATION)

    ;; Apply metadata modifications to registry
    (map-set cognitive-asset-registry
      { asset-identifier: asset-identifier }
      (merge current-asset-data { 
        asset-designation: updated-designation, 
        content-magnitude: updated-magnitude, 
        descriptive-summary: updated-summary, 
        classification-tags: updated-tags 
      })
    )
    (ok true)
  )
)

(define-public (terminate-asset-permanently (asset-identifier uint))
  (let
    (
      (target-asset-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Asset existence and ownership verification protocols
    (asserts! (verify-asset-existence asset-identifier) ERROR_ASSET_NOT_FOUND)
    (asserts! (is-eq (get proprietor-address target-asset-data) tx-sender) ERROR_ACCESS_DENIED)

    ;; Execute permanent asset removal from registry
    (map-delete cognitive-asset-registry { asset-identifier: asset-identifier })
    (ok true)
  )
)

;; --------------------------------------------------------------------------
;; Optimized Data Retrieval Functions
;; --------------------------------------------------------------------------
(define-public (fetch-asset-core-details (asset-identifier uint))
  (let
    (
      (asset-information (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Return essential metadata for optimized retrieval
    (ok {
      asset-designation: (get asset-designation asset-information),
      proprietor-address: (get proprietor-address asset-information),
      content-magnitude: (get content-magnitude asset-information)
    })
  )
)

;; Minimal data extraction function for maximum efficiency
(define-public (extract-asset-minimal-data (asset-identifier uint))
  (let
    (
      (asset-information (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Return only identification data for ultra-compact operations
    (ok {
      asset-designation: (get asset-designation asset-information),
      proprietor-address: (get proprietor-address asset-information)
    })
  )
)

;; Comprehensive asset information retrieval
(define-public (obtain-complete-asset-profile (asset-identifier uint))
  (let
    (
      (comprehensive-asset-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Generate complete asset presentation structure
    (ok {
      title: (get asset-designation comprehensive-asset-data),
      owner: (get proprietor-address comprehensive-asset-data),
      size: (get content-magnitude comprehensive-asset-data),
      abstract: (get descriptive-summary comprehensive-asset-data),
      categories: (get classification-tags comprehensive-asset-data)
    })
  )
)

;; Specialized function for summary extraction
(define-public (extract-asset-summary (asset-identifier uint))
  (let
    (
      (summary-source-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    (ok (get descriptive-summary summary-source-data))
  )
)

;; --------------------------------------------------------------------------
;; Input Validation and Verification Functions
;; --------------------------------------------------------------------------
(define-public (verify-asset-submission-parameters (designation (string-ascii 80)) (magnitude uint) (summary (string-ascii 256)) (tags (list 8 (string-ascii 40))))
  (begin
    ;; Designation validation protocols
    (asserts! (> (len designation) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len designation) u81) ERROR_INVALID_ASSET_DESIGNATION)
    ;; Magnitude validation protocols
    (asserts! (> magnitude u0) ERROR_INVALID_CONTENT_SIZE)
    (asserts! (< magnitude u2000000000) ERROR_INVALID_CONTENT_SIZE)
    ;; Summary validation protocols
    (asserts! (> (len summary) u0) ERROR_INVALID_ASSET_DESIGNATION)
    (asserts! (< (len summary) u257) ERROR_INVALID_ASSET_DESIGNATION)
    ;; Classification structure validation
    (asserts! (validate-classification-structure tags) ERROR_INVALID_ASSET_DESIGNATION)
    (ok true)
  )
)

;; --------------------------------------------------------------------------
;; Internal Utility Functions
;; --------------------------------------------------------------------------
(define-private (verify-asset-existence (asset-identifier uint))
  (is-some (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }))
)

(define-private (confirm-asset-proprietorship (asset-identifier uint) (proprietor principal))
  (match (map-get? cognitive-asset-registry { asset-identifier: asset-identifier })
    asset-record (is-eq (get proprietor-address asset-record) proprietor)
    false
  )
)

(define-private (determine-asset-magnitude (asset-identifier uint))
  (default-to u0 
    (get content-magnitude 
      (map-get? cognitive-asset-registry { asset-identifier: asset-identifier })
    )
  )
)

(define-private (validate-classification-structure (tags (list 8 (string-ascii 40))))
  (and
    (> (len tags) u0)
    (<= (len tags) u8)
    (is-eq (len (filter verify-individual-tag tags)) (len tags))
  )
)

(define-private (verify-individual-tag (tag (string-ascii 40)))
  (and 
    (> (len tag) u0)
    (< (len tag) u41)
  )
)

;; --------------------------------------------------------------------------
;; User Interface Generation Functions
;; --------------------------------------------------------------------------
(define-public (generate-asset-dashboard-view (asset-identifier uint))
  (let
    (
      (dashboard-source-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    ;; Return user interface compatible data structure
    (ok {
      interface-title: "Cognitive Asset Information Dashboard",
      asset-designation: (get asset-designation dashboard-source-data),
      proprietor-address: (get proprietor-address dashboard-source-data),
      descriptive-summary: (get descriptive-summary dashboard-source-data),
      classification-tags: (get classification-tags dashboard-source-data)
    })
  )
)

;; Additional utility function for enhanced asset management
(define-public (validate-asset-ownership-status (asset-identifier uint) (querying-principal principal))
  (let
    (
      (ownership-verification-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    (ok (is-eq (get proprietor-address ownership-verification-data) querying-principal))
  )
)

;; Asset proprietor verification function
(define-public (verify-asset-proprietor-identity (asset-identifier uint))
  (let
    (
      (proprietor-data (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    (ok (get proprietor-address proprietor-data))
  )
)

;; Classification tags extraction utility
(define-public (extract-asset-classification-tags (asset-identifier uint))
  (let
    (
      (classification-source (unwrap! (map-get? cognitive-asset-registry { asset-identifier: asset-identifier }) ERROR_ASSET_NOT_FOUND))
    )
    (ok (get classification-tags classification-source))
  )
)

