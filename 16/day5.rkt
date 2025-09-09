#lang racket

(require threading)
(require openssl/md5)

(require "charnum.rkt")

(define input "cxdnnyjw")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define limit 5)
(define prefix (string->immutable-string (make-string limit #\0)))

(define (zeros of)
  (let loop ([i 0])
    (define hash (md5 (open-input-string (string-append of (number->string i)))))
    (cond
      [(string-prefix? hash prefix)
       (stream-cons #:eager hash (loop (add1 i)))]
      [else (loop (add1 i))])))

(define zero-hashes (zeros input))

(define (solve1)
  (~> zero-hashes
      (stream-take 8)
      (stream-map (lambda~> (string-ref 5)) _)
      stream->list
      list->string))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2)
  (define pw (make-string 8 #\?))
  (let loop ([seq (~> zero-hashes
                    (stream-filter (λ (s) (char<=? #\0 (string-ref s 5) #\7)) _))])
    (define current (stream-first seq))
    (define pos (char->value (string-ref current 5)))
    (when (char=? (string-ref pw pos) #\? )
      (string-set! pw pos (string-ref current 6))
      (println pw))
    (if (string-contains? pw "?")
        (loop (stream-rest seq))
        pw)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-true (string-prefix? (md5 (open-input-string "abc5017308")) "00000"))
   (test-case "Part 1"
              (check-equal? (solve1) "f77a0e6e"))
   (test-case "Part 2"
              (check-equal? (solve2) "999828ec"))))

