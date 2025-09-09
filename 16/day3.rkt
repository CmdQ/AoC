#lang racket

(require threading)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define input (~> "input3.txt"
                file->lines
                (map string-split _)
                (map (lambda~> (map string->number _)) _)))

(define (valid-triangle? sides)
  (match sides
    [(list a b c) (and (> (+ a b) c) (> (+ b c) a) (> (+ c a) b))]))

(define (add1-for-valid three)
  (if (valid-triangle? three) 1 0))

(define (solve1 input)
  (for/sum ([three (in-list input)])
    (add1-for-valid three)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (let loop ([transposed (append* (apply map list input))]
             [count 0])
    (cond
      [(null? transposed) count]
      [else  
       (define-values (head rest) (split-at transposed 3))
       (loop rest (+ count (add1-for-valid head)))])))


(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-equal? (last input) '(356 902 922))
   (test-case "Part 1"
              (check-false (valid-triangle? '(5 10 25)))
              (check-eq? (solve1 input) 917))
   (test-case "Part 2"
              (define example '((101 301 501)
                                (102 302 502)
                                (103 303 503)
                                (201 401 601)
                                (202 402 602)
                                (203 403 603)))
              (check-pred nonnegative-integer? (solve2 example))
              (check-eq? (solve2 input) 1649))))
