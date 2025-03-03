;; Story NFT implementation
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Define story NFT
(define-non-fungible-token story uint)

;; Data structures
(define-map stories
  uint 
  {
    title: (string-utf8 100),
    description: (string-utf8 500),
    creator: principal,
    frames: (list 50 uint),
    likes: uint,
    created-at: uint
  }
)

(define-map story-likes {story-id: uint, user: principal} bool)

;; Data variables
(define-data-var story-id-nonce uint u0)

;; Internal functions
(define-private (get-next-story-id)
  (let ((current-id (var-get story-id-nonce)))
    (var-set story-id-nonce (+ current-id u1))
    current-id
  )
)

;; Public functions
(define-public (create-story (title (string-utf8 100)) (description (string-utf8 500)) (frames (list 50 uint)))
  (let ((story-id (get-next-story-id)))
    (try! (nft-mint? story story-id tx-sender))
    (map-set stories story-id
      {
        title: title,
        description: description,
        creator: tx-sender,
        frames: frames,
        likes: u0,
        created-at: block-height
      }
    )
    (ok story-id)
  )
)

(define-public (like-story (story-id uint))
  (let ((story (unwrap! (map-get? stories story-id) err-not-found)))
    (if (map-get? story-likes {story-id: story-id, user: tx-sender})
      err-unauthorized
      (begin
        (map-set story-likes {story-id: story-id, user: tx-sender} true)
        (map-set stories story-id (merge story {likes: (+ (get likes story) u1)}))
        (ok true)
      )
    )
  )
)

;; Read only functions
(define-read-only (get-story-details (story-id uint))
  (ok (map-get? stories story-id))
)

(define-read-only (get-story-owner (story-id uint))
  (ok (nft-get-owner? story story-id))
)

(define-read-only (has-liked-story (story-id uint) (user principal))
  (ok (map-get? story-likes {story-id: story-id, user: user}))
)
