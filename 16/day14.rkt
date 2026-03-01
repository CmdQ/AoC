#lang racket

(require threading)
(require file/md5)

(define input (make-parameter "qzyelonm"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (hashes input)
  (stream-map (λ (i) (~> i
                         number->string
                         (string-append input _)
                         string->bytes/latin-1
                         md5
                         (cons i _)))
              (in-naturals)))


(define (done? candidates (num 64))
  (let loop ([n 1]
             [elm candidates])
    (match elm
      [(list* (cons _ (? integer?)) _) #f]
      [(list* (cons idx 'done) _)
       #:when (= n num)
       idx]
      [(list* _ rest) (loop (add1 n) rest)]
      [_ #f])))

(define (solve1 input
                (distance 1000)
                #:stretch-function (stretch-function identity))
  (let loop ([hashes (hashes input)]
             [candidates null])
    (cond
      [(done? candidates) => identity]
      [else
       (match-define (cons current hash) (stream-first hashes))
       (define stretched (stretch-function hash))
       ; update candidates
       (define next
         (filter-map
          (match-lambda
            ; keep the ones that are confirmed
            [(and (cons _ 'done) done)
             done]
            ; remove the ones that are surely out
            [(cons past _)
             #:when (> (- current past) distance)
             #f]
            ; confirm new ones
            [(cons past char)
             #:when (regexp-match? (byte-regexp (make-bytes 5 char)) stretched)
             (cons past 'done)]
            ; simply keep the rest
            [unknown unknown])
          candidates))
       ; do we have a new candidate?
       (define new-pair-or-false
         (and~> stretched
                (regexp-match #px#"(.)\\1{2}" _)
                car
                (bytes-ref 0)
                (cons current _)))
       (loop (stream-rest hashes)
             (if new-pair-or-false
                 (append next (list new-pair-or-false))
                 next))])))

(solve1 (input))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (stretch str (repeat 2016))
  (for/fold ([acc str])
            ([I (in-range repeat)])
    (md5 acc)))

(define (solve2 input)
  (solve1 input #:stretch-function stretch))

(solve2 (input))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (check-equal? (md5 "abc0") #"577571be4de9dcce85a041ba0410f29f")
              (check-equal? (solve1 "abc") 22728)
              (check-equal? (solve1 (input)) 15168))
   (test-case "Part 2"
              (check-equal? (solve2 "abc") 22551)
              (check-equal? (solve2 (input)) 20864))))
