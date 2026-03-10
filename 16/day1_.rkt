#lang racket

(require "utils.rkt")
(require threading)

(define input (~> "input.txt"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2



(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-equal? input null)
   (test-case "Part 1")
   (test-case "Part 2")))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) 'TODO))
  (printf "Part two: ~A~%" (must-be (solve2 input) 'TODO)))
