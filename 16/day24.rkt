#lang racket

(require data/queue)
(require threading)
(require racket/list/grouping)
(require "utils.rkt")
(require "matrix.rkt")

(define-values (input positions)
  (let* ([lines (~> "input24.txt" file->lines)]
         [maze (~> lines
                   first
                   string-length
                   (make-matrix (length lines) _))]
         [pos (make-hasheqv)])
    (for ([line (in-list lines)]
          [r (in-naturals)])
      (for ([chr (in-string line)]
            [c (in-naturals)])
        (matrix-set! maze r c chr)
        (when (char<=? #\0 chr #\9)
          (hash-set! pos chr (list r c)))))
    (values maze pos)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define walkable? (compose1 not (curry char=? #\#)))

(define (bfs start goal)
  (define seen (mutable-set start))
  (define q (make-queue))
  (enqueue! q (cons start 0))
  (let loop ()
    (match-define (cons (and (list r c) coords) depth) (dequeue! q))
    (cond
      [(and (= r (first goal))
            (= c (second goal)))
       depth]
      [else
       (for ([dr '(1 0 -1 0)]
             [dc '(0 1 0 -1)]
             #:do ((define next (list (+ r dr) (+ c dc))))
             #:when (and (walkable? (apply matrix-ref input next))
                         (not (set-member? seen next))))
         (enqueue! q (cons next (add1 depth)))
         (set-add! seen next))
       (loop)])))

(define distances
  (delay
    (for*/hash ([(from-char from-coords) (in-hash positions)]
                [(to-char to-coords) (in-hash positions)]
                #:when (char<? from-char to-char))
      (values (list from-char to-char) (bfs from-coords to-coords)))))

(define route-length
  (lambda~>
   (windows 2 1 _)
   ; Since we're only storing half the matrix.
   (map (curryr sort char<?) _)
   (map (lambda~> (hash-ref (force distances) _)) _)
   (foldl + 0 _)))

(define answers
  (delay
    (define big-enough-min (* (hash-count positions) 276))
    (for/fold ([part1 big-enough-min]
               [part2 big-enough-min])
              ([way (~> positions
                        hash-keys
                        (filter (compose1 not (curry char=? #\0)) _)
                        in-permutations)])
      (define there (~> way
                        (cons #\0 _)
                        route-length))
      (define there-and-back (~> way
                                 last
                                 (list #\0 _)
                                 (hash-ref (force distances) _)
                                 (+ there)))
      (values (min part1 there)
              (min part2 there-and-back)))))

(define (solve1)
  (define-values (answer _) (force answers))
  answer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2)
  (define-values (_ answer) (force answers))
  answer)

(module+ main ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Main
  (printf "Part one: ~A~%" (must-be (solve1) 460))
  (printf "Part two: ~A~%" (must-be (solve2) 668)))
