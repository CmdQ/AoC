#lang racket

(require threading)

(require "matrix.rkt")
(require "charnum.rkt")

(define input (~> "input2.txt"
                  file->lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(struct point (x y) #:transparent)

(define (move1 p by)
  (case by
    [(#\U) (point (point-x p) (max 1 (sub1 (point-y p))))]
    [(#\D) (point (point-x p) (min 3 (add1 (point-y p))))]
    [(#\L) (point (max 1 (sub1 (point-x p))) (point-y p))]
    [(#\R) (point (min 3 (add1 (point-x p))) (point-y p))]))

(define (point->square-number p)
  (+ 1 (* 3 (sub1 (point-y p))) (sub1 (point-x p))))

(define (solve1 input)
  (for/fold ([at (point 2 2)]
             [acc null]
             #:result (string-append* (map number->string (reverse acc))))
            ([line input])
    (define eol (for/fold ([at at])
                          ([c line])
                  (move1 at c)))
    (values eol (cons (point->square-number eol) acc))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define dim 5)
(define diamond (make-matrix (+ dim 2) (+ dim 2) #\0))
(for ([r '(1 2 2 2 3 3 3 3 3)]
      [c '(3 2 3 4 1 2 3 4 5)]
      [i (in-range 1 10)])
  (matrix-set! diamond r c (value->char i)))
(for ([r '(4 4 4 5)]
      [c '(2 3 4 3)]
      [l "ABCD"])
  (matrix-set! diamond r c l))

(define (move2 p by)
  (define new
    (case by
      [(#\L) (point (sub1 (point-x p)) (point-y p))]
      [(#\R) (point (add1 (point-x p)) (point-y p))]
      [(#\D) (point (point-x p) (add1 (point-y p)))]
      [(#\U) (point (point-x p) (sub1 (point-y p)))]))
  (if (eq? (matrix-ref diamond (point-y new) (point-x new)) #\0)
      p
      new))

(define (point->diamond-number pos)
  (matrix-ref diamond (point-y pos) (point-x pos)))

(define (solve2 input)
  (for/fold ([at (point 1 3)]
             [acc null]
             #:result (list->string (reverse acc)))
            ([line input])
    (define eol (for/fold ([at at])
                          ([c line])
                  (move2 at c)))
    (values eol (cons (point->diamond-number eol) acc))))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)
  
  (test-begin
   (check-equal? (substring (last input) 0 5) "URDLU")
   (test-case "Part 1"
              (check-eq? (point->square-number (point 3 3)) 9)
              (for ([d "LU"])
                (check-equal? (move1 (point 1 1) d) (point 1 1)))
              (for ([d "DR"])
                (check-equal? (move1 (point 3 3) d) (point 3 3)))
              (check-equal? (move1 (point 2 2) #\R) (point 3 2))
              (check-equal? (move1 (point 2 2) #\U) (point 2 1))
              (check-equal? (solve1 '("ULL" "RRDDD" "LURDL" "UUUUD")) "1985")
              (check-equal? (solve1 input) "78985"))
   (test-case "Part 2"
              (for ([d "LU"])
                (check-equal? (move2 (point 2 2) d) (point 2 2)))
              (for ([d "URD"])
                (check-equal? (move2 (point 5 3) d) (point 5 3)))
              (check-equal? (move2 (point 1 3) #\R) (point 2 3))
              (check-equal? (solve2 input) "57DD8"))))
