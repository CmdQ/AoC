#lang racket/base

(require racket/port)
(require racket/match)
(require racket/list)
(require racket/string)
(require racket/function)
(require threading)

(require "utils.rkt")

(define/match (parse line)
  [((regexp #px"swap position (\\d+) with position (\\d+)"
            (list _ x y)))
   (shadow-as ([string->number x y])
     `(swap-pos ,x ,y))]
  [((regexp #px"swap letter (.) with letter (.)"
            (list _ x y)))
   `(swap-letter ,x ,y)]
  [((regexp #px"rotate (left|right) (\\d+) steps?"
            (list _ dir x)))
   (shadow-as ([string->number x])
     `(,(string->symbol (format "rotate-~A" dir)) ,x))]
  [((regexp #px"rotate based on position of letter (.)"
            (list _ x)))
   `(rotate-letter ,x)]
  [((regexp #px"reverse positions (\\d+) through (\\d+)"
            (list _ x y)))
   (shadow-as ([string->number x y])
     `(reverse ,x ,y))]
  [((regexp #px"move position (\\d+) to position (\\d+)"
            (list _ x y)))
   (shadow-as ([string->number x y])
     `(move-pos ,x ,y))]
  [("") #f])

(define (read-syntax path port)
  (define src-datums (filter-map parse (port->lines port)))
  (define module-datum `(module day21-mod "day21.rkt"
                          ,@src-datums))
  (datum->syntax (quote-syntax here) module-datum))

(define-syntax-rule (module-begin (OP ARG ...) ...)
  (#%module-begin
   (require "utils.rkt")

   (define ops (list (list OP ARG ...) ...))

   (module+ main
     (printf "Part one: ~A~%" (must-be (solve1 "abcdefgh" ops) "dgfaehcb"))
     (printf "Part two: ~A~%" (must-be (solve2 "fbgdceah" ops) "fdhgacbe")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (swap-pos str x y)
  (define mut (string-copy str))
  (define swap (string-ref mut x))
  (string-set! mut x (string-ref mut y))
  (string-set! mut y swap)
  (string->immutable-string mut))

(define (swap-letter str x y)
  (~> str
      (string-replace x "1")
      (string-replace y "2")
      (string-replace "1" y)
      (string-replace "2" x)))

(define (rotate-left str x)
  (define idx (modulo x (string-length str)))
  (string-append (substring str idx)
                 (substring str 0 idx)))

(define (rotate-right str x)
  (rotate-left str (- (string-length str) x)))

(define (rotate-letter str x)
  (define idx (string-find str x))
  (rotate-right str (+ idx 1 (if (>= idx 4) 1 0))))

(define (reverse str x y)
  (string-append (substring str 0 x)
                 (build-string (add1 (- y x))
                               (lambda~> (- y _)
                                         (string-ref str _)))
                 (substring str (add1 y) (string-length str))))

(define (move-pos str x y)
  (cond
    [(= x y) str]
    [(< x y)
     (~> str
         string-length
         (build-string (λ (i) (cond
                                [(or (< i x) (> i y))
                                 (string-ref str i)]
                                [(= i y)
                                 (string-ref str x)]
                                [else
                                 (string-ref str (add1 i))]))))]
    [else
     (define cut (string-ref str x))
     (define without (string-append (substring str 0 x) (substring str (add1 x))))
     (string-append (substring without 0 y) (string cut) (substring without y))]))


(define solve1 (curry foldl (λ (elm acc) (apply (car elm) acc (cdr elm)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (invert-rotate-letter str x)
  (for/first ([i (in-range (string-length str))]
              #:do ((define preimage (rotate-left str i)))
              #:when (equal? (rotate-letter preimage x) str))
    preimage))

(define solve2
  (curry foldr
         (match-lambda**
          [((list (== rotate-left) x) str)
           (rotate-right str x)]
          [((list (== rotate-right) x) str)
           (rotate-left str x)]
          [((list (== move-pos) x y) str)
           (move-pos str y x)]
          [((list (== rotate-letter) x) str)
           (invert-rotate-letter str x)]
          [((list* idem args) str)
           (apply idem str args)])))

(provide read-syntax
         (rename-out (module-begin #%module-begin)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-case "Example"
             (define ex "abcde")
             (define (modify-equal? after with . args)
               (set! ex (apply with ex args))
               (check-equal? ex after))

             (modify-equal? "ebcda" swap-pos 4 0)
             (modify-equal? "edcba" swap-letter "d" "b")
             (modify-equal? "abcde" reverse 0 4)
             (modify-equal? "bcdea" rotate-left 1)
             (modify-equal? "bdeac" move-pos 1 4)
             (modify-equal? "abdec" move-pos 3 0)
             (modify-equal? "ecabd" rotate-letter "b")
             (modify-equal? "decab" rotate-letter "d"))  )
