#lang racket

(require "utils.rkt")
(require threading)
(require file/md5)
(require data/queue)

(define input #"pxxbnzuo")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (open? byte)
  (<= 98 byte 102))

; The order and char (uppercase) is Up, Down, Left, Right.
; The room is 4x4, start is upper left, finished when reaching lower right.
; Only first four chars of MD5 result (hex b-f means open).
(define (solve input xfs)
  (define subtract (bytes-length input))
  (define q (make-queue))
  (define enqueuer (curry (if (eq? xfs 'dfs) enqueue-front! enqueue!) q))
  (enqueuer (list 1 1 input))
  (let loop ([longest 0])
    (cond
      [(queue-empty? q) longest]
      [else
       (match-define (list r c buf) (dequeue! q))
       (cond
         [(= r c 4)
          (if (eq? xfs 'dfs)
              (loop (max longest (- (bytes-length buf) subtract)))
              (subbytes buf (bytes-length input)))]
         [else
          (define hash (md5 buf))
          (define moves
            (filter-map
             (match-lambda
               [(list ch dr dc idx)
                (define nr (+ r dr))
                (define nc (+ c dc))
                (and (<= 1 nr 4) (<= 1 nc 4)
                     (open? (bytes-ref hash idx))
                     (list nr nc (bytes-append buf (bytes (char->integer ch)))))])
             '((#\U -1 0 0)
               (#\D +1 0 1)
               (#\L 0 -1 2)
               (#\R 0 +1 3))))
          (for-each enqueuer moves)
          (loop longest)])])))

(define solve1 (curryr solve 'bfs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define solve2 (curryr solve 'dfs))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (check-equal? (solve1 #"ihgpwlah") #"DDRRRD")
              (check-equal? (solve1 #"kglvqrro") #"DDUDRLRRUDRD")
              (check-equal? (solve1 #"ulqzkmiv") #"DRURDRUDDLLDLUURRDULRLDUUDDDRR"))
   (test-case "Part 2"
              (check-equal? (solve2 #"ihgpwlah") 370)
              (check-equal? (solve2 #"kglvqrro") 492)
              (check-equal? (solve2 #"ulqzkmiv") 830))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input) #"RDULRDDRRD"))
  (printf "Part two: ~A~%" (must-be (solve2 input) 752)))
