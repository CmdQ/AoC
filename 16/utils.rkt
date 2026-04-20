#lang racket/base

(require racket/contract)
(require openssl/md5)

(provide shadow-as
         (contract-out
          [in-drracket? (-> boolean?)]
          [string-md5 (string? . -> . string?)]
          [must-be (any/c any/c . -> . any/c)]
          [bit-count (integer? . -> . integer?)]
          [flip (procedure? . -> . procedure?)]))

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

(define (must-be actual (expected #f))
  (cond
    [(eq? expected 'TODO) (eprintf "must-be: TODO — got ~e~%" actual)]
    [(and expected (not (equal? actual expected)))
     (raise-user-error 'must-be "expected ~e, got ~e" expected actual)])
  actual)

(define string-md5 (compose1 md5 open-input-string))

(define ((flip f) a b) (f b a))

(define (bit-count num)
  (for/sum ([i (in-range (integer-length num))]
            #:when (bitwise-bit-set? num i))
    1))

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
