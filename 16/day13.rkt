#lang debug racket

(require "matrix.rkt")
(require 2htdp/image)
(require threading)
(require data/priority-queue)

(define input (make-parameter 1350))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (bit-count num)
  (let loop ([n num]
             [count 0])
    (cond
      [(negative? n) (error "no negative numbers")]
      [(zero? n) count]
      [else (loop (arithmetic-shift n -1) (+ count (bitwise-and 1 n)))])))

(define +free+ #\.)
(define +wall+ #\#)

(define (free? block) (char=? +free+ block))

(define (brick? x y)
  (let ([formula (+ (sqr x) (* 3 x) (* 2 x y) y (sqr y) (input))])
    (if (even? (bit-count formula))
        +free+
        +wall+)))

(define (create-room width height)
  (define re (make-matrix height width))
  (for* ([r (in-range height)]
         [c (in-range width)])
    (matrix-set! re r c (brick? c r)))
  re)

(define (visualize room)
  (define unit 16)
  (define wall (rectangle unit unit "solid" "black"))
  (define open (rectangle unit unit "solid" "light gray"))
  (~> room
      (matrix-map (λ (c) (if (equal? c +free+) open wall)) _)
      matrix->list-lists
      (map (curry apply beside) _)
      (apply above _)))

(struct point (x y) #:transparent)
(struct node (weight point) #:transparent)

(define (point-in-room? p #:width (width #f) #:height (height #f))
  (match-define (point x y) p)
  (and (nonnegative-integer? x)
       (nonnegative-integer? y)
       (or (not width) (< x width))
       (or (not height) (< y height))))

(define (node<? a b)
  (< (node-weight a) (node-weight b)))

(define (dijkstra room)
  (let* ([source (point 1 1)]
         [Q (make-priority-queue node<? (node 0 source))]
         [prev (make-hash)]
         [dist (make-hash (list (cons source 0)))]
         [w (matrix-cols room)]
         [h (matrix-rows room)])
    (let loop ()
      (cond
        [(zero? (priority-queue-length Q)) (list dist prev)]
        [else
         (match-let* ([(node p u) (priority-queue-remove-max! Q)]
                      [(point x y) u])
           (when (= p (hash-ref dist u))
             (for ([dx '(1 0 -1 0)]
                   [dy '(0 1 0 -1)])
               (define nx (+ x dx))
               (define ny (+ y dy))
               (define v (point nx ny))
               (when (and
                      (point-in-room? v #:width w #:height h)
                      (free? (matrix-ref room ny nx)))
                 (define alt (+ p 1))
                 (when (< alt (hash-ref dist v (add1 alt)))
                   (hash-set! prev v u)
                   (hash-set! dist v alt)
                   (priority-queue-insert! Q (node alt v))))))
           (loop))]))))

(define (solve1 room (x 31) (y 39))
  (define dist-prev (dijkstra room))
  (hash-ref (car dist-prev) (point x y)))

(define example-room (create-room 10 7))
(parameterize ([input 10])
  (match-define (list dist prev) (dijkstra example-room))
  (visualize example-room))

(define big-enough (create-room 52 52))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2)
  (for/sum ([kv (in-hash-pairs (car (dijkstra big-enough)))])
    (if (<= (cdr kv) 50) 1 0)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (parameterize ([input 10])
                (check-equal? (solve1 (create-room 10 7) 7 4) 11))
              (check-equal? (solve1 big-enough) 92))
   (test-case "Part 2"
              (check-equal? (solve2) 124))))
