#lang racket

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
  (printf "Part one: ~A~%" (solve1 input))
  (printf "Part two: ~A~%" (solve2 input)))
