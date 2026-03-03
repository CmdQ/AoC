#lang racket

(require "matrix.rkt")
(require "utils.rkt")
(require 2htdp/image)
(require threading)
(require data/priority-queue)

(define input (make-parameter 1350))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define +free+ #\.)
(define +wall+ #\#)

(define (free? block) (char=? +free+ block))

(define (bit-count num)
  (for/sum ([i (in-range (integer-length num))]
            #:when (bitwise-bit-set? num i))
    1))

(define (which-brick x y)
  (let ([formula (+ (sqr x) (* 3 x) (* 2 x y) y (sqr y) (input))])
    (if (even? (bit-count formula)) +free+ +wall+)))

(define (create-room width height)
  (define re (make-matrix height width))
  (for* ([r (in-range height)]
         [c (in-range width)])
    (matrix-set! re r c (which-brick c r)))
  re)

; The given example room has these dimentions.
(define example-room (create-room 10 7))
; Increased until it didn't crash anymore.
(define big-enough (create-room 52 52))


(define (visualize room #:path [path #()])
  (let* ([unit 16]
         [wall (rectangle unit unit "solid" "black")]
         [open (rectangle unit unit "solid" "light gray")]
         [marker-size (/ unit 3)]
         [start-marker (circle marker-size "solid" "yellow")]
         [goal-marker (circle marker-size "solid" "purple")]
         [path-marker (circle marker-size "solid" "cyan")]
         [path-set (list->set (vector->list path))]
         [start-point (and (> (vector-length path) 0) (vector-ref path 0))]
         [goal-point (and (> (vector-length path) 0) (vector-ref path (sub1 (vector-length path))))]
         [width (matrix-cols room)])
    (apply above
           (for/list ([r (in-range (matrix-rows room))])
             (apply beside
                    (for/list ([c (in-range width)])
                      (let* ([cell (matrix-ref room r c)]
                             [base (if (char=? cell +wall+) wall open)]
                             [p (point c r)])
                        (cond
                          [(equal? p start-point) (overlay start-marker base)]
                          [(equal? p goal-point) (overlay goal-marker base)]
                          [(set-member? path-set p) (overlay path-marker base)]
                          [else base]))))))))

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

(define +source+ (point 1 1))

(define (dijkstra room)
  (let* ([Q (make-priority-queue node<? (node 0 +source+))]
         [prev (make-hash)]
         [dist (make-hash (list (cons +source+ 0)))]
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

; 31/39 is the target from part 1.
(define (solve1 room (x 31) (y 39))
  (hash-ref (first (dijkstra room)) (point x y)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2)
  ; How many are reachable in at most 50 steps?
  (for/sum ([kv (in-hash-pairs (first (dijkstra big-enough)))])
    (if (<= (cdr kv) 50) 1 0)))

(define (build-path current prevs (acc null))
  (cond
    [(equal? current +source+) (list->vector (cons +source+ acc))]
    [else
     (define pred (hash-ref prevs current))
     (build-path pred prevs (cons current acc))]))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (parameterize ([input 10])
                (check-equal? (solve1 (create-room 10 7) 7 4) 11))
              (check-equal? (solve1 big-enough) 92))
   (test-case "Part 2"
              (check-equal? (solve2) 124))))

(module+ main ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Visualization
  (printf "Part one: ~A~%" (solve1 big-enough))
  (printf "Part two: ~A~%" (solve2))
  ; For the viz, switch to the example's favorite number.
  (when (in-drracket?)
    (parameterize ([input 10])
      (visualize example-room
                 #:path (build-path (point 7 4)
                                    (second (dijkstra example-room)))))
    (visualize big-enough
               #:path (build-path (point 31 39)
                                  (second (dijkstra big-enough))))))
