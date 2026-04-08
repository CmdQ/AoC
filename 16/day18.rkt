#lang racket

(require "utils.rkt")
(require "nint.rkt")
(require threading)

(define trap #\^)

(define (trap->integer str)
  (for/fold ([re 0])
            ([c (in-string str)])
    (bitwise-ior (arithmetic-shift re 1)
                 (if (char=? c trap) 1 0))))

(define input-str
  ".^^..^...^..^^.^^^.^^^.^^^^^^.^.^^^^.^^.^^^^^^.^...^......^...^^^..^^^.....^^^^^^^^^....^^...^^^^..^")

(define input
  (~> input-str
      trap->integer
      (nint (string-length input-str))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define/match (step line)
  [((nint num bits))
   (define mask (sub1 (arithmetic-shift 1 bits)))
   (define xored (~> (list 1 -1)
                     (map (lambda~> (arithmetic-shift num _)) _)
                     (map (lambda~> (bitwise-and mask)) _)
                     (apply bitwise-xor _)))
   (nint xored bits)])

(define/match (count-traps row)
  [((nint num bits))
   (- bits (bit-count num))])

(define (solve input (rows 40))
  (for/fold ([cur input]
             [acc (list (count-traps input))]
             #:result (foldl + 0 acc))
            ([_ (in-range (sub1 rows))])
    (define once (step cur))
    (values once
            (cons (count-traps once) acc))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve input) 2005))
  (printf "Part two: ~A~%" (must-be (solve input 400000) 20008491)))
