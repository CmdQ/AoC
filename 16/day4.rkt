#lang racket

(require threading)

(struct room (name sector checksum) #:transparent)

(define (string->room str)
  (match (regexp-match #rx"([a-z-]+)-([0-9]+)[[]([a-z]+)[]]" str)
    [(list asd name id chk)
     (room name (string->number id) chk)]))

(define input (~> "input4.txt"
                  file->lines
                  (map string->room _)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define limit 5)

(define (letter-hash str)
  (define ht (make-hash))
  (for ([c (in-string str)])
    (when (not (eqv? c #\-))
      (hash-update! ht c add1 0)))
  (hash->list ht))

(define (valid? room)
  (define result (letter-hash (room-name room)))

  ; Sort twice, alphabetically first, then decreasing number.
  (for ([f (list car cdr)]
        [cmp (list char<? >)])
    (set! result (sort result #:key f cmp)))

  (~> result
      (take limit)
      (map car _)
      list->string
      (string=? (room-checksum room))))

(define (solve1 input)
  (set! input (filter valid? input))
  (~> input
      (map room-sector _)
      (apply + _)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define the-a (char->integer #\a))
(define (decrypt amount str)
  (list->string
   (for/list ([c str])
     (case c
       [(#\-) #\space]
       [else (~> c
                 char->integer
                 (- the-a)
                 (+ amount)
                 (modulo 26)
                 (+ the-a)
                 (integer->char))]))))

(define (solve2 input)
  (for/first ([r (in-list input)]
              #:when (equal? (decrypt (room-sector r) (room-name r))
                             "northpole object storage"))
    (room-sector r)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-equal? (last input) (room "bxaxipgn-vgpst-qphzti-rdcipxcbtci" 635 "ipctx"))
   (test-case "Part 1"
              (for ([yes (list "aaaaa-bbb-z-y-x-123[abxyz]"
                               "a-b-c-d-e-f-g-h-987[abcde]"
                               "not-a-real-room-404[oarel]")])
                (check-true (valid? (string->room yes))))
              (check-false (valid? (string->room "totally-real-room-200[decoy]")))
              (= (solve1 input) 361724))
   (test-case "Part 2"
              (check-equal? (decrypt 343 "qzmt-zixmtkozy-ivhz") "very encrypted name")
              (check-equal? (solve2 input) 482))))
