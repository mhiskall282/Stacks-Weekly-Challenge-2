;; Notepad/Task Manager Contract - Talent Protocol Compliant
;; Each note or task is recorded as a transaction on the blockchain
;; Users pay a small fee (in STX) for each note they create
;; Follows Talent Protocol guidelines for builder activity tracking

;; Error codes
(define-constant ERR_NOT_ENOUGH_STX (err u1001))
(define-constant ERR_NOTE_NOT_FOUND (err u1002))
(define-constant ERR_UNAUTHORIZED (err u1003))
(define-constant ERR_INVALID_TITLE (err u1004))
(define-constant ERR_INVALID_INPUT (err u1005))

;; Constants - Talent Protocol Compliance
(define-constant NOTE_FEE u10000) ;; 0.01 STX in microstacks (lowered for testnet challenge)
(define-constant MIN_TITLE_LENGTH u1)
(define-constant MAX_TITLE_LENGTH u100)
(define-constant MAX_CONTENT_LENGTH u500)
(define-constant MAX_PRIORITY_LENGTH u10)
(define-constant MAX_STATUS_LENGTH u20)
(define-constant MAX_NOTES_PER_USER u500)

;; Talent Protocol metadata - for builder tracking
(define-constant PROTOCOL_VERSION u1)
(define-constant BUILDER_FEATURE "notepad-on-stacks")

;; Contract owner
(define-constant CONTRACT_OWNER tx-sender)

;; Data structures
;; Each note has: title, content, priority, status, creation time, and owner
(define-map notes
  uint
  {
    title: (string-ascii 100),
    content: (string-ascii 500),
    priority: (string-ascii 10),
    status: (string-ascii 20),
    created-at: uint,
    updated-at: uint,
    owner: principal,
    is-deleted: bool,
  }
)

;; Map to track user's note IDs for quick lookup
(define-map user-notes
  principal
  (list 500 uint)
)

;; Track builder activity for Talent Protocol
(define-map builder-stats
  principal
  {
    total-notes-created: uint,
    total-fees-paid: uint,
    last-activity: uint,
  }
)

;; Counter for note IDs
(define-data-var note-counter uint u0)

;; Counter for total fees collected
(define-data-var total-fees uint u0)

;; Counter for total transactions
(define-data-var total-transactions uint u0)

;; PUBLIC FUNCTIONS

;; Create a new note (transaction-based)
;; Caller pays NOTE_FEE to create a note
;; Talent Protocol: Each transaction counts as builder activity
(define-public (create-note (title (string-ascii 100)) (content (string-ascii 500)) (priority (string-ascii 10)))
  (let ((note-id (+ (var-get note-counter) u1))
        (current-notes (default-to (list) (map-get? user-notes tx-sender)))
        (current-stats (default-to 
          { total-notes-created: u0, total-fees-paid: u0, last-activity: u0 }
          (map-get? builder-stats tx-sender))))
    
    ;; Validate inputs
    (asserts! (> (len title) u0) ERR_INVALID_TITLE)
    (asserts! (< (len title) u101) ERR_INVALID_TITLE)
    (asserts! (< (len content) u501) ERR_INVALID_INPUT)
    (asserts! (< (len priority) u11) ERR_INVALID_INPUT)
    (asserts! (< (len current-notes) u501) ERR_INVALID_INPUT)
    
    ;; Transfer fee from caller to contract
    (unwrap! (stx-transfer? NOTE_FEE tx-sender (as-contract tx-sender)) ERR_NOT_ENOUGH_STX)
    
    ;; Store the note
    (map-set notes note-id {
      title: title,
      content: content,
      priority: priority,
      status: "active",
      created-at: burn-block-height,
      updated-at: burn-block-height,
      owner: tx-sender,
      is-deleted: false,
    })
    
    ;; Add note ID to user's note list
    (map-set user-notes tx-sender (unwrap! (as-max-len? (append current-notes note-id) u500) ERR_INVALID_INPUT))
    
    ;; Update builder stats for Talent Protocol
    (map-set builder-stats tx-sender {
      total-notes-created: (+ (get total-notes-created current-stats) u1),
      total-fees-paid: (+ (get total-fees-paid current-stats) NOTE_FEE),
      last-activity: burn-block-height,
    })
    
    ;; Increment counters
    (var-set note-counter note-id)
    (var-set total-fees (+ (var-get total-fees) NOTE_FEE))
    (var-set total-transactions (+ (var-get total-transactions) u1))
    
    ;; Emit event - Talent Protocol compliant
    (print {
      event: "NoteCreated",
      protocol: "talent-protocol",
      feature: BUILDER_FEATURE,
      note-id: note-id,
      title: title,
      priority: priority,
      creator: tx-sender,
      fee-paid: NOTE_FEE,
      timestamp: burn-block-height,
      version: PROTOCOL_VERSION,
    })
    
    (ok note-id)))

;; Update an existing note
(define-public (update-note (note-id uint) (new-content (string-ascii 500)) (new-status (string-ascii 20)))
  (let ((note (unwrap! (map-get? notes note-id) ERR_NOTE_NOT_FOUND)))
    
    ;; Verify the caller owns this note and it's not deleted
    (asserts! (is-eq tx-sender (get owner note)) ERR_UNAUTHORIZED)
    (asserts! (not (get is-deleted note)) ERR_NOTE_NOT_FOUND)
    
    ;; Validate inputs
    (asserts! (< (len new-content) u501) ERR_INVALID_INPUT)
    (asserts! (< (len new-status) u21) ERR_INVALID_INPUT)
    
    ;; Transfer fee for update (half of creation fee)
    (unwrap! (stx-transfer? (/ NOTE_FEE u2) tx-sender (as-contract tx-sender)) ERR_NOT_ENOUGH_STX)
    
    ;; Update the note
    (map-set notes note-id
      (merge note {
        content: new-content,
        status: new-status,
        updated-at: burn-block-height,
      })
    )
    
    ;; Update builder stats
    (let ((current-stats (default-to 
      { total-notes-created: u0, total-fees-paid: u0, last-activity: u0 }
      (map-get? builder-stats tx-sender))))
      (map-set builder-stats tx-sender {
        total-notes-created: (get total-notes-created current-stats),
        total-fees-paid: (+ (get total-fees-paid current-stats) (/ NOTE_FEE u2)),
        last-activity: burn-block-height,
      }))
    
    ;; Update total fees
    (var-set total-fees (+ (var-get total-fees) (/ NOTE_FEE u2)))
    (var-set total-transactions (+ (var-get total-transactions) u1))
    
    ;; Emit event
    (print {
      event: "NoteUpdated",
      protocol: "talent-protocol",
      feature: BUILDER_FEATURE,
      note-id: note-id,
      new-status: new-status,
      updater: tx-sender,
      fee-paid: (/ NOTE_FEE u2),
      timestamp: burn-block-height,
    })
    
    (ok note-id)))

;; Complete/Archive a note
(define-public (complete-note (note-id uint))
  (let ((note (unwrap! (map-get? notes note-id) ERR_NOTE_NOT_FOUND)))
    
    ;; Verify ownership and not deleted
    (asserts! (is-eq tx-sender (get owner note)) ERR_UNAUTHORIZED)
    (asserts! (not (get is-deleted note)) ERR_NOTE_NOT_FOUND)
    
    ;; Update status to completed
    (map-set notes note-id
      (merge note {
        status: "completed",
        updated-at: burn-block-height,
      })
    )
    
    ;; Update transaction counter
    (var-set total-transactions (+ (var-get total-transactions) u1))
    
    ;; Emit event
    (print {
      event: "NoteCompleted",
      protocol: "talent-protocol",
      feature: BUILDER_FEATURE,
      note-id: note-id,
      title: (get title note),
      completed-by: tx-sender,
      timestamp: burn-block-height,
    })
    
    (ok true)))

;; Delete a note (soft delete for audit trail)
(define-public (delete-note (note-id uint))
  (let ((note (unwrap! (map-get? notes note-id) ERR_NOTE_NOT_FOUND)))
    
    ;; Verify ownership
    (asserts! (is-eq tx-sender (get owner note)) ERR_UNAUTHORIZED)
    (asserts! (not (get is-deleted note)) ERR_NOTE_NOT_FOUND)
    
    ;; Mark as deleted (soft delete)
    (map-set notes note-id
      (merge note {
        is-deleted: true,
        updated-at: burn-block-height,
      })
    )
    
    ;; Update transaction counter
    (var-set total-transactions (+ (var-get total-transactions) u1))
    
    ;; Emit event
    (print {
      event: "NoteDeleted",
      protocol: "talent-protocol",
      feature: BUILDER_FEATURE,
      note-id: note-id,
      deleted-by: tx-sender,
      timestamp: burn-block-height,
    })
    
    (ok true)))

;; READ-ONLY FUNCTIONS

;; Get a specific note
(define-read-only (get-note (note-id uint))
  (match (map-get? notes note-id)
    note 
      (if (get is-deleted note)
        none
        (some note))
    none))

;; Get all notes for a user
(define-read-only (get-user-notes (user principal))
  (map-get? user-notes user))

;; Get note count for a user
(define-read-only (get-user-note-count (user principal))
  (match (map-get? user-notes user)
    notes-list (len notes-list)
    u0))

;; Get total notes created
(define-read-only (get-total-notes)
  (var-get note-counter))

;; Get total fees collected
(define-read-only (get-total-fees)
  (var-get total-fees))

;; Get total transactions on platform
(define-read-only (get-total-transactions)
  (var-get total-transactions))

;; Get contract balance
(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender)))

;; Get builder stats for Talent Protocol
(define-read-only (get-builder-stats (builder principal))
  (map-get? builder-stats builder))

;; Get active notes for a user (not deleted)
(define-read-only (get-active-note-count (user principal))
  (match (map-get? user-notes user)
    notes-list (len notes-list)
    u0))
