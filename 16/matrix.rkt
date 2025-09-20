#lang racket

(require racket/generator)

(provide (contract-out
          [make-matrix
           ([positive-integer? positive-integer?] [any/c] . ->* . matrix?)]
          [matrix-rows (matrix? . -> . nonnegative-integer?)]
          [matrix-cols (matrix? . -> . nonnegative-integer?)]
          [matrix-ref (matrix? nonnegative-integer? nonnegative-integer? . -> . any)]
          [matrix-set! (matrix? nonnegative-integer? nonnegative-integer? any/c . -> . void?)]
          [in-matrix (matrix? . -> . sequence?)]))

(struct matrix (rows cols data) #:transparent)

(define (make-matrix rows cols [init 0])
  (matrix rows cols (make-vector (* rows cols) init)))

(define (matrix-index m row col)
  (+ (* row (matrix-cols m)) col))

(define (matrix-ref m row col)
  (vector-ref (matrix-data m) (matrix-index m row col)))

(define (matrix-set! m row col val)
  (vector-set! (matrix-data m) (matrix-index m row col) val))

(define (in-matrix m)
  (in-generator
   (for* ([r (in-range (matrix-rows m))]
          [c (in-range (matrix-cols m))])
     (yield (matrix-ref m r c)))))
