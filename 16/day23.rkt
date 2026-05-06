#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)

(require "utils.rkt")
(require (only-in "day12.rkt"
                  (parse parse12)))

(define/match (parse line)
  [((regexp #px"tgl ([a-d])"
            (list _ reg)))
   (shadow-as ([string->symbol reg])
     `(toggle ,reg))]
  [(_) (parse12 line)])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day23-mod "day23-runtime.rkt"
                          '(,@src-datums)))
  (datum->syntax (quote-syntax here) module-datum))

(provide read-syntax)
