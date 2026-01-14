#lang racket/base

(require racket/generator)
(require racket/vector)
(require racket/contract)
(require racket/math)

(provide (contract-out
          [make-matrix
           ([positive-integer? positive-integer?] [any/c] . ->* . matrix?)]
          [matrix-rows (matrix? . -> . nonnegative-integer?)]
          [matrix-cols (matrix? . -> . nonnegative-integer?)]
          [matrix-ref (matrix? nonnegative-integer? nonnegative-integer? . -> . any)]
          [matrix-set! (matrix? nonnegative-integer? nonnegative-integer? any/c . -> . void?)]
          [matrix-map ((any/c . -> . any/c) matrix? . -> . matrix?)]
          [in-matrix (matrix? . -> . sequence?)]
          [in-matrix-rows (matrix? . -> . sequence?)]
          [matrix->list-lists (matrix? . -> . (listof (listof any/c)))]))

(struct matrix (rows cols data) #:transparent)

(define (make-matrix rows cols [init 0])
  (matrix rows cols (make-vector (* rows cols) init)))

(define (matrix-index m row col)
  (define rows (matrix-cols m))
  (define cols (matrix-cols m))
  (cond
    [(>= row rows)
     (error 'matrix-index "invalid row index ~a with height ~a" row rows)]
    [(>= col cols)
     (error 'matrix-index "invalid column index ~a with width ~a" col cols)]
    [else (+ (* row rows) col)]))

(define (matrix-ref m row col)
  (vector-ref (matrix-data m) (matrix-index m row col)))

(define (matrix-set! m row col val)
  (vector-set! (matrix-data m) (matrix-index m row col) val))

(define (matrix-map proc m)
  (matrix (matrix-rows m) (matrix-cols m) (vector-map proc (matrix-data m))))

(define (in-matrix m)
  (in-generator
   (for* ([r (in-range (matrix-rows m))]
          [c (in-range (matrix-cols m))])
     (yield (matrix-ref m r c)))))

(define (in-matrix-rows m)
  (define count (matrix-cols m))
  (define vec (matrix-data m))
  (in-generator
   (for ([i (in-range (matrix-rows m))])
     (yield (vector-take (vector-drop vec (* i count)) count)))))

(define (matrix->list-lists m)
  (for/list ([r (in-range (matrix-rows m))])
    (for/list ([c (in-range (matrix-cols m))])
      (matrix-ref m r c))))