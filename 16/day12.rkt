#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)
(require racket/string)

(require "utils.rkt")

(define (is-register? thing)
  (if (string-contains? "abcd" thing)
      (string->symbol thing)
      #f))

(define/match (parse line)
  [((regexp #px"(inc|dec) ([a-d])"
            (list _ func reg)))
   (shadow-as ([string->symbol reg])
     `(,(string->symbol (string-append func "rement")) ,reg))]
  [((regexp #px"jnz ([a-d]|-?\\d+) (-?\\d+)"
            (list _ compare ahead)))
   (shadow-as ([string->number ahead])
     (cond
       [(is-register? compare)
        `(jump-not-zero (read ,(string->symbol compare)) ,ahead)]
       [else
        `(jump-not-zero ,(string->number compare) ,ahead)]))]
  [((regexp #px"cpy ([a-d]|-?\\d+) ([a-d])" (list _ src dst)))
   (shadow-as ([string->symbol dst])
     (cond
       [(is-register? src)
        `(copy (read ,(string->symbol src)) ,dst)]
       [else
        `(copy ,(string->number src) ,dst)]))]
  [("") (void)])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day12-mod "day12-runtime.rkt"
                          '(,@src-datums)))
  (datum->syntax (quote-syntax here) module-datum))

(provide read-syntax)