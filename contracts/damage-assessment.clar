;; Damage Assessment Contract
;; Evaluates and tracks infrastructure damage after emergencies

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-INVALID-ASSESSMENT-ID (err u401))
(define-constant ERR-INVALID-DAMAGE-LEVEL (err u402))
(define-constant ERR-INVALID-PRIORITY (err u403))
(define-constant ERR-ASSESSMENT-COMPLETED (err u404))

;; Damage severity levels
(define-constant DAMAGE-NONE u0)
(define-constant DAMAGE-MINOR u1)
(define-constant DAMAGE-MODERATE u2)
(define-constant DAMAGE-MAJOR u3)
(define-constant DAMAGE-SEVERE u4)
(define-constant DAMAGE-DESTROYED u5)

;; Assessment status
(define-constant STATUS-PENDING u1)
(define-constant STATUS-IN-PROGRESS u2)
(define-constant STATUS-COMPLETED u3)
(define-constant STATUS-VERIFIED u4)

;; Infrastructure types
(define-constant INFRA-RESIDENTIAL u1)
(define-constant INFRA-COMMERCIAL u2)
(define-constant INFRA-INDUSTRIAL u3)
(define-constant INFRA-PUBLIC u4)
(define-constant INFRA-UTILITIES u5)
(define-constant INFRA-TRANSPORTATION u6)

;; Priority levels
(define-constant PRIORITY-LOW u1)
(define-constant PRIORITY-MEDIUM u2)
(define-constant PRIORITY-HIGH u3)
(define-constant PRIORITY-CRITICAL u4)

;; Data Variables
(define-data-var assessment-counter uint u0)
(define-data-var total-estimated-damage uint u0)
(define-data-var assessments-completed uint u0)

;; Damage assessments
(define-map damage-assessments
  { assessment-id: uint }
  {
    location: { x: uint, y: uint },
    infrastructure-type: uint,
    damage-level: uint,
    estimated-cost: uint,
    priority: uint,
    assessed-by: principal,
    assessed-at: uint,
    status: uint,
    description: (string-ascii 500),
    photos-hash: (optional (string-ascii 64)),
    repair-timeline: uint,
    safety-hazard: bool
  }
)

;; Infrastructure registry
(define-map infrastructure-registry
  { infrastructure-id: (string-ascii 50) }
  {
    infrastructure-type: uint,
    location: { x: uint, y: uint },
    owner: (string-ascii 100),
    construction-year: uint,
    last-inspection: uint,
    current-condition: uint,
    insurance-info: (string-ascii 200),
    critical-services: bool
  }
)

;; Assessment teams
(define-map assessment-teams
  { team-id: (string-ascii 50) }
  {
    lead-assessor: principal,
    team-members: (list 10 (string-ascii 50)),
    specialization: (string-ascii 100),
    is-available: bool,
    current-assignments: uint,
    certification-level: uint
  }
)

;; Repair estimates
(define-map repair-estimates
  { assessment-id: uint }
  {
    labor-cost: uint,
    material-cost: uint,
    equipment-cost: uint,
    total-cost: uint,
    estimated-duration: uint,
    contractor-recommendations: (list 5 (string-ascii 100)),
    permit-requirements: (string-ascii 200)
  }
)

;; Verification records
(define-map assessment-verifications
  { assessment-id: uint, verifier: principal }
  {
    verified-at: uint,
    verification-notes: (string-ascii 300),
    damage-level-confirmed: bool,
    cost-estimate-approved: bool,
    priority-adjustment: (optional uint)
  }
)

;; Public Functions

;; Create new damage assessment
(define-public (create-assessment (location-x uint) (location-y uint) (infrastructure-type uint) (damage-level uint) (estimated-cost uint) (description (string-ascii 500)))
  (let
    (
      (assessment-id (+ (var-get assessment-counter) u1))
      (current-time block-height)
      (priority (calculate-priority damage-level infrastructure-type))
    )
    (asserts! (is-authorized-assessor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= damage-level u0) (<= damage-level u5)) ERR-INVALID-DAMAGE-LEVEL)
    (asserts! (and (>= infrastructure-type u1) (<= infrastructure-type u6)) (err u405))

    (map-set damage-assessments
      { assessment-id: assessment-id }
      {
        location: { x: location-x, y: location-y },
        infrastructure-type: infrastructure-type,
        damage-level: damage-level,
        estimated-cost: estimated-cost,
        priority: priority,
        assessed-by: tx-sender,
        assessed-at: current-time,
        status: STATUS-COMPLETED,
        description: description,
        photos-hash: none,
        repair-timeline: (calculate-repair-timeline damage-level),
        safety-hazard: (>= damage-level u3)
      }
    )

    (var-set assessment-counter assessment-id)
    (var-set total-estimated-damage (+ (var-get total-estimated-damage) estimated-cost))
    (var-set assessments-completed (+ (var-get assessments-completed) u1))
    (ok assessment-id)
  )
)

;; Update assessment status
(define-public (update-assessment-status (assessment-id uint) (new-status uint))
  (let
    (
      (assessment-data (unwrap! (map-get? damage-assessments { assessment-id: assessment-id }) ERR-INVALID-ASSESSMENT-ID))
    )
    (asserts! (is-authorized-assessor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= new-status u1) (<= new-status u4)) (err u406))

    (map-set damage-assessments
      { assessment-id: assessment-id }
      (merge assessment-data { status: new-status })
    )
    (ok true)
  )
)

;; Add repair estimate
(define-public (add-repair-estimate (assessment-id uint) (labor-cost uint) (material-cost uint) (equipment-cost uint) (duration uint))
  (let
    (
      (total-cost (+ (+ labor-cost material-cost) equipment-cost))
    )
    (asserts! (is-authorized-assessor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? damage-assessments { assessment-id: assessment-id })) ERR-INVALID-ASSESSMENT-ID)

    (map-set repair-estimates
      { assessment-id: assessment-id }
      {
        labor-cost: labor-cost,
        material-cost: material-cost,
        equipment-cost: equipment-cost,
        total-cost: total-cost,
        estimated-duration: duration,
        contractor-recommendations: (list),
        permit-requirements: "Standard building permits required"
      }
    )
    (ok true)
  )
)

;; Verify assessment
(define-public (verify-assessment (assessment-id uint) (verification-notes (string-ascii 300)) (damage-confirmed bool) (cost-approved bool))
  (let
    (
      (current-time block-height)
      (assessment-data (unwrap! (map-get? damage-assessments { assessment-id: assessment-id }) ERR-INVALID-ASSESSMENT-ID))
    )
    (asserts! (is-authorized-verifier tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status assessment-data) STATUS-COMPLETED) (err u407))

    (map-set assessment-verifications
      { assessment-id: assessment-id, verifier: tx-sender }
      {
        verified-at: current-time,
        verification-notes: verification-notes,
        damage-level-confirmed: damage-confirmed,
        cost-estimate-approved: cost-approved,
        priority-adjustment: none
      }
    )

    (map-set damage-assessments
      { assessment-id: assessment-id }
      (merge assessment-data { status: STATUS-VERIFIED })
    )
    (ok true)
  )
)

;; Register infrastructure
(define-public (register-infrastructure (infrastructure-id (string-ascii 50)) (infrastructure-type uint) (location-x uint) (location-y uint) (owner (string-ascii 100)) (construction-year uint))
  (let
    (
      (current-time block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set infrastructure-registry
      { infrastructure-id: infrastructure-id }
      {
        infrastructure-type: infrastructure-type,
        location: { x: location-x, y: location-y },
        owner: owner,
        construction-year: construction-year,
        last-inspection: current-time,
        current-condition: u1, ;; Good condition initially
        insurance-info: "Insurance information pending",
        critical-services: (is-eq infrastructure-type INFRA-UTILITIES)
      }
    )
    (ok true)
  )
)

;; Create assessment team
(define-public (create-assessment-team (team-id (string-ascii 50)) (lead-assessor principal) (specialization (string-ascii 100)) (certification-level uint))
  (begin
    (asserts! (is-authorized-manager tx-sender) ERR-NOT-AUTHORIZED)

    (map-set assessment-teams
      { team-id: team-id }
      {
        lead-assessor: lead-assessor,
        team-members: (list),
        specialization: specialization,
        is-available: true,
        current-assignments: u0,
        certification-level: certification-level
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get assessment details
(define-read-only (get-assessment (assessment-id uint))
  (map-get? damage-assessments { assessment-id: assessment-id })
)

;; Get repair estimate
(define-read-only (get-repair-estimate (assessment-id uint))
  (map-get? repair-estimates { assessment-id: assessment-id })
)

;; Get infrastructure info
(define-read-only (get-infrastructure-info (infrastructure-id (string-ascii 50)))
  (map-get? infrastructure-registry { infrastructure-id: infrastructure-id })
)

;; Get assessment team info
(define-read-only (get-assessment-team (team-id (string-ascii 50)))
  (map-get? assessment-teams { team-id: team-id })
)

;; Get damage statistics
(define-read-only (get-damage-statistics)
  (ok {
    total-assessments: (var-get assessment-counter),
    completed-assessments: (var-get assessments-completed),
    total-estimated-damage: (var-get total-estimated-damage),
    average-damage-per-assessment: (if (> (var-get assessments-completed) u0)
      (/ (var-get total-estimated-damage) (var-get assessments-completed))
      u0
    )
  })
)

;; Get assessments by priority
(define-read-only (get-high-priority-count)
  ;; Simplified implementation - in practice would filter all assessments
  u0
)

;; Private Functions

;; Check if user is authorized assessor
(define-private (is-authorized-assessor (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    ;; Add additional authorization logic here
    false
  )
)

;; Check if user is authorized verifier
(define-private (is-authorized-verifier (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    ;; Add additional authorization logic here
    false
  )
)

;; Check if user is authorized manager
(define-private (is-authorized-manager (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    ;; Add additional authorization logic here
    false
  )
)

;; Calculate priority based on damage level and infrastructure type
(define-private (calculate-priority (damage-level uint) (infrastructure-type uint))
  (if (>= damage-level u4)
    PRIORITY-CRITICAL
    (if (or (is-eq infrastructure-type INFRA-UTILITIES) (is-eq infrastructure-type INFRA-PUBLIC))
      (if (>= damage-level u2) PRIORITY-HIGH PRIORITY-MEDIUM)
      (if (>= damage-level u3) PRIORITY-HIGH
        (if (>= damage-level u2) PRIORITY-MEDIUM PRIORITY-LOW)
      )
    )
  )
)

;; Calculate repair timeline based on damage level
(define-private (calculate-repair-timeline (damage-level uint))
  (if (is-eq damage-level DAMAGE-MINOR)
    u7 ;; 1 week
    (if (is-eq damage-level DAMAGE-MODERATE)
      u30 ;; 1 month
      (if (is-eq damage-level DAMAGE-MAJOR)
        u90 ;; 3 months
        (if (is-eq damage-level DAMAGE-SEVERE)
          u180 ;; 6 months
          u365 ;; 1 year for destroyed
        )
      )
    )
  )
)
