#lang racket

(require "utils.rkt")
(require "matrix.rkt")
(require threading)
(require 2htdp/image)

(struct usage (size used available percent) #:transparent)

(define rows 32)
(define cols 30)

(define correct-matrix (curry make-matrix rows cols))

(define input (let ([m (correct-matrix)])
                (for ([line (in-list (file->lines "input22.txt"))]
                      #:when (string-prefix? line "/dev/grid/"))
                  (define matches
                    (regexp-match
                     #px"/dev/grid/node-x(\\d+)-y(\\d+) +(\\d+)T +(\\d+)T +(\\d+)T +(\\d+)%"
                     line))
                  (match-define (list* x y rest) (map string->number (cdr matches)))
                  (matrix-set! m y x (apply usage rest)))
                m))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (solve1 input)
  (for*/sum ([a (in-matrix input)]
             [b (in-matrix input)]
             #:when (and (not (equal? a b))
                         (positive? (usage-used a))
                         (<= (usage-used a) (usage-available b))))
    1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

; /dev/grid/node-x29-y0    87T   66T    21T   75%
; /dev/grid/node-x11-y22   92T    0T    92T    0%
; Next smallest used is 64 and second largest available is 30.
(define (solve2 input)
  (if (in-drracket?)
      (~> (let* ([unit 16])
            (apply above
                   (for/list ([r (in-range rows)])
                     (apply beside
                            (for/list ([c (in-range cols)])
                              (define drive (matrix-ref input r c))
                              (define filled (truncate (* 255 (/ (usage-percent drive) 100))))
                              (rectangle unit unit "solid" (make-color filled filled filled)))))))
          println)
      (when #f
        (for ([r (in-range rows)])
          (for ([c (in-range cols)])
            (match-define (usage _ used avail _) (matrix-ref input r c))
            (display (cond
                       ; full enough that no other node's data would fit
                       [(and (<= avail 64)
                             ; small enough that their data could be moved around
                             (<= used 92))
                        #\.]
                       [(zero? used)
                        #\_]
                       [(>= used 92)
                        #\#])))
          (displayln ""))))
  
  (+ 7 ; move the hole up
     4 ; then left
     15 ; then up
     21 ; and to the right stopping 1 early
     (* 5 28) ; rotate data along with whole to the left
     1 ; final data into hole
     ))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)
  
  (test-begin
   (test-case "Part 2"
              (check-true (> (solve2 input) 178)))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) 937))
  (printf "Part two: ~A~%" (must-be (solve2 input) 188)))
