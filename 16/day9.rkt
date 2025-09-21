#lang racket

(require)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define marker-regex #px"(\\d+)x(\\d+)")

(define (read-marker port)
  (let loop ([acc null])
    (define c (read-char port))
    (cond
      [(eof-object? c) (error "unexpected EOF in marker")]
      [(char=? c #\)) (apply string (reverse acc))]
      [else (loop (cons c acc))])))

(define (decompress1 port)
  (let loop ([acc 0]
             [skip 0])
    (define c (read-char port))
    (cond
      [(eof-object? c) acc]
      [(positive? skip) (loop acc (sub1 skip))]
      [(char-whitespace? c) (loop acc 0)]
      [(and (equal? c #\() (zero? skip))
       (define m (regexp-match marker-regex (read-marker port)))
       (unless m (error "marker doesn't match"))
       (let ([repeated (string->number (second m))]
             [count (string->number (third m))])
         (loop (+ acc (* repeated count)) repeated))]
      [else
       (loop (add1 acc) 0)])))

(define ((solve solver) (input #f))
  (if input
      (solver (open-input-string input))
      (call-with-input-file "input9.txt" solver #:mode 'text)))

(define solve1 (solve decompress1))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (decompress2 port)
  (let loop ([acc 0])
    (define c (read-char port))
    (cond
      [(eof-object? c) acc]
      [(char-whitespace? c) (loop acc)]
      [(equal? c #\()
       (define m (regexp-match marker-regex (read-marker port)))
       (unless m (error "marker doesn't match"))
       (let ([repeated (string->number (second m))]
             [count (string->number (third m))])
         (loop (+ acc (* count (solve2 (read-string repeated port))))))]
      [else
       (loop (add1 acc))])))

(define solve2 (solve decompress2))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (for ([in '("ADVENT" "A(1x5)BC" "(3x3)XYZ" "A(2x2)BCD(2x2)EFG" "(6x1)(1x3)A" "X(8x2)(3x3)ABCY")]
                    [ex '(6 7 9 11 6 18)])
                (check-equal? (solve1 in) ex in))
              (check-equal? (solve1) 98135))
   (test-case "Part 2"
              (for ([in '("(3x3)XYZ" "X(8x2)(3x3)ABCY" "(27x12)(20x12)(13x14)(7x10)(1x12)A" "(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")]
                    [ex (list 9 (string-length "XABCABCABCABCABCABCY") 241920 445)])
                (check-equal? (solve2 in) ex in))
              (check-equal? (solve2 #f) 10964557606))))
