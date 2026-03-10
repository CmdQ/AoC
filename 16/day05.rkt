#lang racket

(require "utils.rkt")
(require threading)

(require "charnum.rkt")

(define input "cxdnnyjw")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define limit 5)
(define prefix (string->immutable-string (make-string limit #\0)))

(define (zeros of)
  (let loop ([i 0])
    (define hash (string-md5 (string-append of (number->string i))))
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
   (check-true (string-prefix? (string-md5 "abc5017308") "00000"))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1) "f77a0e6e"))
  (printf "Part two: ~A~%" (must-be (solve2) "999828ec")))
