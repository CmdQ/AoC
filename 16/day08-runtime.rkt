#lang racket

(require "matrix.rkt")
(require "utils.rkt")

(define width 50)
(define height 6)
(define screen (make-matrix height width 0))

(define (rect! w h)
  (for* ([r (in-range h)]
         [c (in-range w)])
    (matrix-set! screen r c 1)))

(define (rotate-row! r amount)
  (define temp (for/vector ([i (in-range width)])
                 (matrix-ref screen r (remainder (+ i (- width amount)) width))))
  (for ([i (in-range width)])
    (matrix-set! screen r i (vector-ref temp i))))

(define (rotate-column! c amount)
  (define temp (for/vector ([i (in-range height)])
                 (matrix-ref screen (remainder (+ i (- height amount)) height) c)))
  (for ([i (in-range height)])
    (matrix-set! screen i c (vector-ref temp i))))

(define (solve1)
  (for/sum ([e (in-matrix screen)]) e))

(define (solve2)
  (for ([(c i) (in-indexed (in-matrix screen))])
    (when (zero? (remainder i width))
      (displayln ""))
    (display (if (zero? c) " " "#"))))

(define-syntax day8-module-begin
  (syntax-rules ()
    [(_ body ...)
     (#%module-begin
      body ...
      (printf "Part one: ~A~%Part two:" (must-be (solve1) 121))
      (solve2)
      (displayln ""))]))

(provide rect! rotate-row! rotate-column!
         (rename-out (day8-module-begin #%module-begin)))
