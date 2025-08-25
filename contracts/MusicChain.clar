;; MusicChain: Music Composition and Practice Reward System
;; Version: 1.0.0

;; Constants
(define-constant STUDIO_CAPACITY u2800000)
(define-constant BASE_PRACTICE_REWARD u32)
(define-constant COMPOSITION_BONUS u18)
(define-constant MAX_MUSICIAN_LEVEL u20)
(define-constant ERR_INVALID_MUSIC_ACTIVITY u1)
(define-constant ERR_NO_MUSIC_TOKENS u2)
(define-constant ERR_STUDIO_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_MUSIC_SEASON u2160)
(define-constant RECORDING_MULTIPLIER u10)
(define-constant MIN_RECORDING_PERIOD u1080)
(define-constant EARLY_RELEASE_PENALTY u30)

;; Data Variables
(define-data-var total-music-tokens-distributed uint u0)
(define-data-var total-music-activities uint u0)
(define-data-var studio-producer principal tx-sender)

;; Data Maps
(define-map musician-activities principal uint)
(define-map musician-music-tokens principal uint)
(define-map practice-session-start-time principal uint)
(define-map musician-skill-level principal uint)
(define-map musician-last-activity principal uint)
(define-map musician-recording-project principal uint)
(define-map musician-recording-start-block principal uint)
(define-map composition-complexity principal uint)
(define-map musician-performance-count principal uint)
(define-map instrument-mastery principal uint)

;; Public Functions
(define-public (start-practice-session (instrument-type uint) (difficulty-level uint))
  (let
    (
      (musician tx-sender)
    )
    (asserts! (and (> instrument-type u0) (> difficulty-level u0) (<= difficulty-level u10)) (err ERR_INVALID_MUSIC_ACTIVITY))
    (map-set practice-session-start-time musician burn-block-height)
    (map-set composition-complexity musician difficulty-level)
    (ok true)
  ))

(define-public (complete-practice-session (instrument-type uint) (performance-quality uint))
  (let
    (
      (musician tx-sender)
      (start-block (default-to u0 (map-get? practice-session-start-time musician)))
      (blocks-practicing (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? musician-last-activity musician)))
      (skill-level (default-to u0 (map-get? musician-skill-level musician)))
      (capped-skill (if (<= skill-level MAX_MUSICIAN_LEVEL) skill-level MAX_MUSICIAN_LEVEL))
      (performance-bonus (/ (* performance-quality u10) u100))
      (instrument-bonus (default-to u0 (map-get? instrument-mastery musician)))
      (practice-reward (+ BASE_PRACTICE_REWARD (* capped-skill COMPOSITION_BONUS) performance-bonus instrument-bonus))
    )
    (asserts! (and (> start-block u0) (>= blocks-practicing instrument-type) (<= performance-quality u100)) (err ERR_INVALID_MUSIC_ACTIVITY))
    
    (map-set musician-activities musician (+ (default-to u0 (map-get? musician-activities musician)) u1))
    (map-set musician-music-tokens musician (+ (default-to u0 (map-get? musician-music-tokens musician)) practice-reward))
    
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_MUSIC_SEASON)
      (map-set musician-skill-level musician (+ skill-level u1))
      (map-set musician-skill-level musician u1)
    )
    
    (if (>= performance-quality u90)
      (map-set instrument-mastery musician (+ instrument-bonus u5))
      true
    )
    
    (map-set musician-last-activity musician burn-block-height)
    (var-set total-music-activities (+ (var-get total-music-activities) u1))
    (var-set total-music-tokens-distributed (+ (var-get total-music-tokens-distributed) practice-reward))
    
    (asserts! (<= (var-get total-music-tokens-distributed) STUDIO_CAPACITY) (err ERR_STUDIO_CAPACITY_EXCEEDED))
    (ok practice-reward)
  ))

(define-public (claim-music-rewards)
  (let
    (
      (musician tx-sender)
      (token-balance (default-to u0 (map-get? musician-music-tokens musician)))
    )
    (asserts! (> token-balance u0) (err ERR_NO_MUSIC_TOKENS))
    (map-set musician-music-tokens musician u0)
    (ok token-balance)
  ))

;; Recording Features
(define-public (start-recording-project (project-scope uint))
  (let
    (
      (musician tx-sender)
    )
    (asserts! (> project-scope u0) (err ERR_INVALID_MUSIC_ACTIVITY))
    (asserts! (>= (var-get total-music-tokens-distributed) project-scope) (err ERR_STUDIO_CAPACITY_EXCEEDED))
    
    (map-set musician-recording-project musician project-scope)
    (map-set musician-recording-start-block musician burn-block-height)
    (var-set total-music-tokens-distributed (- (var-get total-music-tokens-distributed) project-scope))
    (ok project-scope)
  ))

(define-public (release-recording)
  (let
    (
      (musician tx-sender)
      (recording-amount (default-to u0 (map-get? musician-recording-project musician)))
      (recording-start-block (default-to u0 (map-get? musician-recording-start-block musician)))
      (blocks-recording (- burn-block-height recording-start-block))
      (penalty (if (< blocks-recording MIN_RECORDING_PERIOD) (/ (* recording-amount EARLY_RELEASE_PENALTY) u100) u0))
      (recording-bonus (if (>= blocks-recording MIN_RECORDING_PERIOD) (/ (* recording-amount RECORDING_MULTIPLIER) u100) u0))
      (final-amount (+ (- recording-amount penalty) recording-bonus))
    )
    (asserts! (> recording-amount u0) (err ERR_NO_MUSIC_TOKENS))
    
    (map-set musician-recording-project musician u0)
    (map-set musician-recording-start-block musician u0)
    (map-set musician-performance-count musician (+ (default-to u0 (map-get? musician-performance-count musician)) u1))
    (var-set total-music-tokens-distributed (+ (var-get total-music-tokens-distributed) final-amount))
    (ok final-amount)
  ))

(define-public (compose-original-piece (genre-type uint) (composition-length uint))
  (let
    (
      (musician tx-sender)
      (skill-level (default-to u0 (map-get? musician-skill-level musician)))
      (performance-count (default-to u0 (map-get? musician-performance-count musician)))
      (composition-bonus (+ (* genre-type u15) (* performance-count u8)))
    )
    (asserts! (and (> genre-type u0) (> composition-length u0) (>= skill-level u7)) (err ERR_INVALID_MUSIC_ACTIVITY))
    
    (map-set musician-music-tokens musician (+ (default-to u0 (map-get? musician-music-tokens musician)) composition-bonus))
    (var-set total-music-tokens-distributed (+ (var-get total-music-tokens-distributed) composition-bonus))
    
    (ok composition-bonus)
  ))

(define-public (collaborate-with-musicians (collaborator-count uint) (project-complexity uint))
  (let
    (
      (musician tx-sender)
      (skill-level (default-to u0 (map-get? musician-skill-level musician)))
      (collaboration-bonus (+ (* collaborator-count u25) (* project-complexity u12)))
    )
    (asserts! (and (> collaborator-count u0) (> project-complexity u0) (>= skill-level u5)) (err ERR_INVALID_MUSIC_ACTIVITY))
    
    (map-set musician-music-tokens musician (+ (default-to u0 (map-get? musician-music-tokens musician)) collaboration-bonus))
    (var-set total-music-tokens-distributed (+ (var-get total-music-tokens-distributed) collaboration-bonus))
    
    (ok collaboration-bonus)
  ))

;; Read-Only Functions
(define-read-only (get-music-activity-count (user principal))
  (default-to u0 (map-get? musician-activities user)))

(define-read-only (get-music-token-balance (user principal))
  (default-to u0 (map-get? musician-music-tokens user)))

(define-read-only (get-skill-level (user principal))
  (default-to u0 (map-get? musician-skill-level user)))

(define-read-only (get-performance-count (user principal))
  (default-to u0 (map-get? musician-performance-count user)))

(define-read-only (get-recording-project (user principal))
  (default-to u0 (map-get? musician-recording-project user)))

(define-read-only (get-instrument-mastery (user principal))
  (default-to u0 (map-get? instrument-mastery user)))

(define-read-only (get-studio-stats)
  {
    total-music-activities: (var-get total-music-activities),
    total-music-tokens-distributed: (var-get total-music-tokens-distributed),
    studio-capacity: STUDIO_CAPACITY
  })

(define-read-only (calculate-practice-reward (skill-level uint) (performance-quality uint) (instrument-bonus uint))
  (let
    (
      (capped-skill (if (<= skill-level MAX_MUSICIAN_LEVEL) skill-level MAX_MUSICIAN_LEVEL))
      (performance-bonus (/ (* performance-quality u10) u100))
    )
    (+ BASE_PRACTICE_REWARD (* capped-skill COMPOSITION_BONUS) performance-bonus instrument-bonus)
  ))

;; Private Functions
(define-private (is-studio-producer)
  (is-eq tx-sender (var-get studio-producer)))

(define-private (validate-music-parameters (instrument-type uint) (performance-quality uint))
  (and (> instrument-type u0) (<= performance-quality u100)))