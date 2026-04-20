#lang racket

(require "utils.rkt")
(require threading)

(define input (~> "input.txt"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (solve1 input)
  #f)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  #f)

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1")
   (test-case "Part 2")))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) 'TODO))
  (printf "Part two: ~A~%" (must-be (solve2 input) 'TODO)))
