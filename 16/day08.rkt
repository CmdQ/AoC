#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)

(require "utils.rkt")

(define/match (parse line)
  [((pregexp #px"rect (\\d+)x(\\d+)"
             (list _ rows cols)))
   (shadow-as ([string->number rows cols])
     `(rect! ,rows ,cols))]
  [((pregexp #px"rotate (row y|column x)=(\\d+) by (\\d+)"
             (list _ what num amount)))
   (shadow-as ([string->number num amount])
     (define fname (string->symbol
                    (string-append "rotate-"
                                   (substring what 0 (- (string-length what) 2))
                                   "!")))
     `(,fname ,num ,amount))]
  [("") #f])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day8-mod "day8-runtime.rkt"
                          ,@src-datums))
  (datum->syntax (quote-syntax here) module-datum))

(provide read-syntax)