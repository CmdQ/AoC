#lang racket/base

(require racket/contract)
(require openssl/md5)

(provide shadow-as
         (contract-out
          [in-drracket? (-> boolean?)]
          [string-md5 (string? . -> . string?)]))

(require (for-syntax racket/base syntax/parse))

(define (in-drracket?)
  (regexp-match? #px"(?i:drracket|gracket)"
                 (path->string (find-system-path 'exec-file))))

(define-syntax (shadow-as stx)
  (syntax-parse stx
    [(_ ([f:id v:id ...] ...) body ...)
     (define binding-stxs
       (for*/list ([grp (in-list (syntax->list #'([f v ...] ...)))]
                   [v   (in-list (cdr (syntax->list grp)))])
         (define f-stx (car (syntax->list grp)))
         #`[#,v (#,f-stx #,v)]))
     #`(let (#,@binding-stxs) body ...)]))

(define string-md5 (compose1 md5 open-input-string))

(module+ test
  (require rackunit)
  (define from "1")
  (define low-id "2")
  (define high-id "3")
  (define tag "foo")
  (check-equal? (shadow-as ([string->number from low-id high-id]
                            [string->symbol tag])
                  (list from low-id high-id tag)) '(1 2 3 foo))
  (check-equal? (shadow-as ([string->number]) 4) 4)
  (check-equal? (shadow-as () 4) 4))
