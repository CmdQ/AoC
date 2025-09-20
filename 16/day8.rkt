#lang racket

(require threading)
(require "matrix.rkt")

(define width 50)
(define height 6)
(define screen (make-matrix height width 0))

(define (parse-line line)
  (cond
    [(regexp-match #px"rect (\\d+)x(\\d+)" line)
     => (λ (m)
          (let ([snd (string->number (second m))]
                [trd (string->number (third m))])
            (λ () (rect! screen snd trd))))]
    [(regexp-match #px"rotate row y=(\\d+) by (\\d+)" line)
     => (λ (m)
          (let ([snd (string->number (second m))]
                [trd (string->number (third m))])
            (λ () (rotate-row! screen snd trd))))]
    [(regexp-match #px"rotate column x=(\\d+) by (\\d+)" line)
     => (λ (m)
          (let ([snd (string->number (second m))]
                [trd (string->number (third m))])
            (λ () (rotate-col! screen snd trd))))]))

(define input (~> "input8.txt"
                  file->lines
                  (map parse-line _)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (rect! scr w h)
  (for* ([r (in-range h)]
         [c (in-range w)])
    (matrix-set! scr r c 1)))

(define (rotate-row! scr r amount)
  (define temp (for/vector ([i (in-range width)]) (matrix-ref scr r (remainder (+ i (- width amount)) width))))
  (for ([i (in-range width)])
    (matrix-set! scr r i (vector-ref temp i))))

(define (rotate-col! scr c amount)
  (define temp (for/vector ([i (in-range height)]) (matrix-ref scr (remainder (+ i (- height amount)) height) c)))
  (for ([i (in-range height)])
    (matrix-set! scr i c (vector-ref temp i))))

(define (solve1 input)
  (for-each (λ (thunk) (thunk)) input)
  (for/sum ([e (in-matrix screen)]) e))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2)
  (for ([(c i) (in-indexed (in-matrix screen))])
    (when (zero? (remainder i width))
      (displayln ""))
    (display (if (zero? c) " " "#"))))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)
  
  (test-begin
   (test-case "Part 1"
              (check-equal? (solve1 input) 121))
   (test-case "Part 2"
              (check-not-equal? (solve2) "RURUCEOEIL"))))
