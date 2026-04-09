#lang racket

(require "utils.rkt")
(require threading)
(require data/queue)

(define input 3005290)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (solve1 input)
  (define q (make-queue))
  (for ([i (in-range input)])
    (enqueue! q (cons i 1)))
  (let loop ()
    (match-define (cons name count) (dequeue! q))
    (cond
      [(queue-empty? q)
       (~> name
           add1)]
      [else
       (~> q
           dequeue!
           cdr
           (+ count)
           (cons name _)
           (enqueue! q _))
       (loop)])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (define q1 (make-queue))
  (define q2 (make-queue))
  (define middle (quotient input 2))
  (for ([i (in-range middle)])
    (enqueue! q1 (cons i 1)))
  (for ([i (in-range middle input)])
    (enqueue! q2 (cons i 1)))
  (let loop ()
    (define len1 (queue-length q1))
    (cond
      [(> (- (queue-length q2) len1) 1) ; Difference of 1 must be ok.
       ; Rebalance takes priority.
       (~> q2
           dequeue!
           (enqueue! q1 _))
       (loop)]
      [(zero? len1) ; Has to come after.
       ; We're done.
       (~> q2
           dequeue!
           car
           add1)]
      [else
       (match-define (cons name1 count1) (dequeue! q1))
       (~> q2
           dequeue!
           cdr
           (+ count1)
           (cons name1 _)
           (enqueue! q2 _))
       (loop)])))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (check-equal? (solve1 5) 3))
   (test-case "Part 2"
              (check-equal? (solve2 5) 2))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) 1816277))
  (printf "Part two: ~A~%" (must-be (solve2 input) 1410967)))
