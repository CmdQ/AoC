#lang racket/base

(require racket/contract)
(require racket/math)
(require racket/match)

(provide (contract-out
          [struct nint ((number exact-integer?) (bits exact-nonnegative-integer?))]
          [make-nint (->* (exact-integer?) ((or/c exact-integer? #f)) nint?)]
          [nint-mask ((or/c nint? exact-integer?) . -> . exact-integer?)]
          [logical-shift (nint? exact-integer? . -> . nint?)]))

(struct nint (number bits) #:transparent)

(define (make-nint integer (bits-length #f))
  (nint integer (or bits-length (integer-length integer))))

(define/match (nint-mask nint-or-width)
  [((or (nint _ shift)
        (and (? exact-integer?) shift)))
   (sub1 (arithmetic-shift 1 shift))])

(define/match (logical-shift nnum amount)
  [((nint num bits) _)
   (define shifted (arithmetic-shift num amount))
   (nint (if (negative? amount)
             (bitwise-and (nint-mask bits) shifted)
             shifted)
         bits)])

(module+ test
  (require rackunit)

  (test-case "make-nint infers bit length"
             (check-equal? (make-nint #b110) (nint 6 3))
             (check-equal? (make-nint #b1) (nint 1 1))
             (check-equal? (make-nint 0) (nint 0 0)))

  (test-case "make-nint with explicit bit length"
             (check-equal? (make-nint #b110 5) (nint 6 5))
             (check-equal? (make-nint 0 8) (nint 0 8)))

  (test-case "nint-mask"
             ; from nint
             (check-equal? (nint-mask (make-nint #b1010)) #b1111)
             (check-equal? (nint-mask (nint 0 8)) 255)
             ; from explicit width
             (check-equal? (nint-mask 3) #b111)
             (check-equal? (nint-mask 1) 1)
             (check-equal? (nint-mask 0) 0))

  (test-case "logical-shift"
             ; left shift — no masking needed
             (check-equal? (logical-shift (make-nint #b101 3) 1) (nint #b1010 3))
             ; right shift — masks to width, filling with 0s
             (check-equal? (logical-shift (make-nint #b110 3) -1) (nint #b011 3))
             ; right shift drops LSB
             (check-equal? (logical-shift (make-nint #b1011 4) -2) (nint #b0010 4))
             ; preserves bits field
             (check-equal? (nint-bits (logical-shift (make-nint 0 8) 3)) 8)))
