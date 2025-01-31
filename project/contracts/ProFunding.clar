
;; title: ProFunding
;; version: 1.0
;; summary:
;; description:

;; Project Funding Platform Smart Contract

;; Error Constants
(define-constant error-access-denied (err u1))
(define-constant error-item-not-found (err u2))
(define-constant error-invalid-input (err u3))
(define-constant error-insufficient-funds (err u4))

;; Contract Admin
(define-constant contract-admin tx-sender)

;; Contract State
(define-data-var contract-state (string-ascii 20) "inactive")
(define-data-var project-counter uint u0)

;; Data Maps
(define-map project-details uint {
    title: (string-ascii 50),
    description: (string-utf8 500),
    funding-goal: uint,
    deadline: uint,
    owner: principal
})

(define-map project-votes uint (map principal bool))
(define-map project-contributions uint (map principal uint))
(define-map member-profiles principal {
    role: (string-ascii 20),
    status: (string-ascii 20)
})

;; Private Functions

(define-private (is-contract-admin)
    (is-eq tx-sender contract-admin)
)

(define-private (is-active-member (member principal))
    (match (get status (map-get? member-profiles member))
        status (is-eq status "active")
        false
    )
)

;; Member Management Functions

(define-public (onboard-new-member (new-member principal))
    (begin
        (asserts! (is-active-member tx-sender) error-access-denied)
        (ok (map-set member-profiles new-member {
            role: "contributor",
            status: "active"
        }))
    )
)

(define-public (offboard-member (member principal))
    (begin
        (asserts! (or (is-contract-admin) (is-eq tx-sender member)) error-access-denied)
        (ok (map-delete member-profiles member))
    )
)

;; Project Management Functions

(define-public (register-project (project-title (string-ascii 50)) 
                               (project-description (string-utf8 500))
                               (funding-goal uint)
                               (project-deadline uint))
    (let ((project-id (+ (var-get project-counter) u1)))
        (begin
            ;; Input validation
            (asserts! (is-active-member tx-sender) error-access-denied)
            (asserts! (> (len project-title) u0) error-invalid-input)
            (asserts! (> (len project-description) u0) error-invalid-input)
            (asserts! (> funding-goal u0) error-invalid-input)
            (asserts! (> project-deadline block-height) error-invalid-input)
            
            ;; Store project details
            (map-set project-details project-id {
                title: project-title,
                description: project-description,
                funding-goal: funding-goal,
                deadline: project-deadline,
                owner: tx-sender
            })
            
            ;; Update project counter
            (var-set project-counter project-id)
            (ok project-id)
        )
    )
)

;; Voting System

(define-public (cast-vote (project-id uint) (vote bool))
    (begin
        (asserts! (is-active-member tx-sender) error-access-denied)
        (asserts! (map-get? project-details project-id) error-item-not-found)
        (ok (map-set project-votes project-id 
            (match (map-get? project-votes project-id)
                existing-votes (merge existing-votes {tx-sender: vote})
                (map-new {tx-sender: vote})
            )
        ))
    )
)

(define-read-only (get-votes (project-id uint))
    (ok (map-get? project-votes project-id))
)

;; Fund Management

(define-public (contribute-funds (project-id uint) (contribution-amount uint))
    (let ((project (map-get? project-details project-id)))
        (begin
            (asserts! (is-active-member tx-sender) error-access-denied)
            (asserts! project error-item-not-found)
            (asserts! (>= (stx-get-balance tx-sender) contribution-amount) error-insufficient-funds)
            (asserts! (<= block-height (get deadline project)) error-invalid-input)
            
            ;; Transfer funds
            (try! (stx-transfer? contribution-amount tx-sender (as-contract tx-sender)))
            
            ;; Record contribution
            (ok (map-set project-contributions project-id 
                (match (map-get? project-contributions project-id)
                    existing-contributions (merge existing-contributions 
                        {tx-sender: (+ (default-to u0 (get tx-sender existing-contributions)) contribution-amount)})
                    (map-new {tx-sender: contribution-amount})
                )
            ))
        )
    )
)

(define-public (withdraw-funds (project-id uint))
    (let ((project (map-get? project-details project-id))
          (project-balance (get-project-balance project-id)))
        (begin
            (asserts! project error-item-not-found)
            (asserts! (is-eq tx-sender (get owner project)) error-access-denied)
            (asserts! (>= block-height (get deadline project)) error-invalid-input)
            (asserts! (>= project-balance (get funding-goal project)) error-insufficient-funds)
            
            ;; Transfer funds to project owner
            (as-contract (stx-transfer? project-balance tx-sender (get owner project)))
        )
    )
)

(define-read-only (get-project-balance (project-id uint))
    (default-to u0 
        (fold + u0 
            (map-get? project-contributions project-id)))
)

;; Read-only Functions

(define-read-only (get-project-details (project-id uint))
    (ok (map-get? project-details project-id))
)

(define-read-only (get-member-profile (member principal))
    (ok (map-get? member-profiles member))
)

;; Contract Initialization

(define-public (activate-contract)
    (begin
        (asserts! (is-eq tx-sender contract-admin) error-access-denied)
        (asserts! (is-eq (var-get contract-state) "inactive") error-invalid-input)
        (var-set contract-state "active")
        (map-set member-profiles contract-admin {
            role: "admin",
            status: "active"
        })
        (ok true)
    )
)

;; Initialize contract
(activate-contract)