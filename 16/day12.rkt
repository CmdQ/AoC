#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)
(require racket/function)

(require "utils.rkt")

(define parse-or-symbol
  (disjoin string->number string->symbol))

(define/match (parse line)
  [((regexp #px"(inc|dec) ([a-d])"
            (list _ func reg)))
   (shadow-as ([string->symbol reg])
     `(,(string->symbol (string-append func "rement")) ,reg))]
  [((regexp #px"jnz ([a-d]|-?\\d+) ([a-d]|-?\\d+)"
            (list _ compare ahead)))
   `(jump-not-zero ,(parse-or-symbol compare) ,(parse-or-symbol ahead))]
  [((regexp #px"cpy ([a-d]|-?\\d+) ([a-d])" (list _ src dst)))
   (shadow-as ([string->symbol dst])
     `(copy ,(parse-or-symbol src) ,dst))]
  [("") (void)])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day12-mod "day12-runtime.rkt"
                          '(,@src-datums)))
  (datum->syntax (quote-syntax here) module-datum))

(provide read-syntax)