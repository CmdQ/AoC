#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)

(require "utils.rkt")
(require "matrix.rkt")

(define width 50)
(define height 6)
(define screen (make-matrix height width 0))

(define (rect! w h)
  (for* ([r (in-range h)]
         [c (in-range w)])
    (matrix-set! screen r c 1)))

(define (rotate-row! r amount)
  (define temp (for/vector ([i (in-range width)]) (matrix-ref screen r (remainder (+ i (- width amount)) width))))
  (for ([i (in-range width)])
    (matrix-set! screen r i (vector-ref temp i))))

(define (rotate-column! c amount)
  (define temp (for/vector ([i (in-range height)]) (matrix-ref screen (remainder (+ i (- height amount)) height) c)))
  (for ([i (in-range height)])
    (matrix-set! screen i c (vector-ref temp i))))

(define/match (parse line)
  [((pregexp #px"rect (\\d+)x(\\d+)"
             (list _ rows cols)))
   (shadow-as ([string->number rows cols])
     `(rect! ,rows ,cols))]
  [((pregexp #px"rotate (row y|column x)=(\\d+) by (\\d+)"
             (list _ what num amount)))
   (shadow-as ([string->number num amount])
     (define fname
       (string->symbol
        (string-append "rotate-"
                       (substring what 0 (- (string-length what) 2))
                       "!")))
     `(,fname ,num ,amount))]
  [("") #f])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day8-mod "day8.rkt"
                          ,@src-datums))
  (datum->syntax (quote-syntax here) module-datum))

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
      (require rackunit)
      body ...
      (define answer1 (solve1))
      (printf "Answer 1: ~A~%Answer 2:" answer1)
      (solve2)
      (displayln "")
      (check-equal? answer1 121))]))

(provide read-syntax
         rect!
         rotate-row!
         rotate-column!
         (rename-out (day8-module-begin #%module-begin))
         #%app
         #%datum)