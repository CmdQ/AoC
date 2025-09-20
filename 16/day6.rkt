#lang racket

(require threading)

(require "charnum.rkt")

(define input (~> "input6.txt"
                  file->lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (vector-what vec func)
  (for/fold ([pos 0]
             [acc (vector-ref vec 0)])
            ([i (in-range (vector-length vec))])
    (define current (vector-ref vec i))
    (cond
      [(func current acc) (values i current)]
      [else (values pos acc)])))

(define (histograms input)
  (define length (string-length (first input)))
  (define counts (for/vector ([i (in-range length)]) (make-vector 26 0)))
  (for ([line input])
    (for ([i (in-range length)])
      (define pos (letter->integer (string-ref line i)))
      (define vec (vector-ref counts i))
      (vector-set! vec pos (add1 (vector-ref vec pos)))))
  counts)

(define (solve input cmp)
  (define counts (histograms input))
  (list->string (for/list ([vec counts])
                  (define-values (pos max) (vector-what vec cmp))
                  (integer->char (+ pos (char->integer #\a))))))

(define (solve1 input)
  (solve input >))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (solve input <))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (define example '("eedadn"
                    "drvtee"
                    "eandsr"
                    "raavrd"
                    "atevrs"
                    "tsrnev"
                    "sdttsa"
                    "rasrtv"
                    "nssdts"
                    "ntnada"
                    "svetve"
                    "tesnvt"
                    "vntsnd"
                    "vrdear"
                    "dvrsen"
                    "enarar"))

  (test-begin
   (check-equal? (last input) "islgcrgm")
   (test-case "Part 1"
              (check-equal? (solve1 example) "easter")
              (check-equal? (solve1 input) "gebzfnbt"))
   (test-case "Part 2"
              (check-equal? (solve2 input) "fykjtwyn"))))

