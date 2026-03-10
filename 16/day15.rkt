#lang racket

(require "utils.rkt")
(require threading)

(define input
  (for/list ([line (file->lines "input15.txt")])
    (match line
      [(pregexp #px"Disc #\\d has (\\d+) positions; at time=0, it is at position (\\d+)." (list _ mod rem))
       (~> (list rem mod)
           (map string->number _)
           (apply cons _))])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

;; Returns gcd(a,b) and Bézout coefficients s, t such that a·s + b·t = gcd(a,b).
;; s is the modular inverse of a mod b when gcd = 1.
(define (egcd a b)
  (let loop ([a a]
             [b b]
             [x 0]
             [y 1]
             [u 1]
             [v 0])
    (cond
      [(zero? a)
       (values b x y)]
      [else
       (define-values (q r) (quotient/remainder b a))
       (loop r a u v (- x (* u q)) (- y (* v q)))])))

(define (solve1 input)
  (define as (map car input))
  (define mods (map cdr input))
  (define N (foldl * 1 mods))
  (define ys (map (lambda~> (/ N _)) mods))
  (define zs (map (λ (yi mi) (match-define-values (_ b _) (egcd yi mi)) b) ys mods))
  (modulo (for/sum ([a as]
                    [i (in-naturals 1)]
                    [y ys]
                    [z zs])
            (* (- 0 a i) y z)) N))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (define longer (append input '((0 . 11))))
  (solve1 longer))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-case "Part 1"
             (check-equal? (solve1 '((4 . 5) (1 . 2))) 5)))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) 376777))
  (printf "Part two: ~A~%" (must-be (solve2 input) 3903937)))
