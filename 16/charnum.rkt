#lang racket

(provide (contract-out
          [digits->number (list? . -> . exact-nonnegative-integer?)]
          [char->value (char? . -> . exact-nonnegative-integer?)]
          [value->char (exact-nonnegative-integer? . -> . char?)]))

(define (digits->number digits)
  (foldl (λ (d res) (+ (* 10 res) d)) 0 digits))

(define (char->value char)
  (cond
    [(char<=? #\0 char #\9) (- (char->integer char) (char->integer #\0))]
    [else (raise-argument-error 'char-value "char-numeric?" char)]))

(define (value->char num)
  (cond
    [(<= 0 num 9) (integer->char (+ num (char->integer #\0)))]
    [else (raise-arguments-error 'char->value
                                 "only single digits accepted"
                                 "num" num)]))

(module+ test
  (require rackunit)
  (test-case "digits to number"
             (for ([exa '(() (0) (1) (31337))]
                   [exp '(0 0 1 31337)])
               (check-equal? (digits->number exa) exp)))
  (test-case "single digits to chars"
             (for ([i (in-range 10)]
                   [c "0123456789"])
               (check-equal? (value->char i) c))
             (check-exn
              exn:fail:contract?
              (λ () (value->char -1)))
             (check-exn
              exn:fail:contract?
              (λ () (value->char 10))))
  (test-case "numeric value of chars"
             (for ([d "0123456789"]
                   [i (in-range 10)])
               (check-equal? (char->value d) i))
             (for ([n "qwe!$#/.,"])
               (check-exn
                exn:fail:contract?
                (λ () (char->value n))))))