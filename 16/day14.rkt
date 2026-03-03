#lang racket

(require threading)
(require file/md5)

(define input (make-parameter "qzyelonm"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(struct ring (vec (last #:auto #:mutable)) #:transparent #:auto-value -1)

(define (make-ring size)
  (ring (make-vector size #"")))

(define (ring-wrap rb idx)
  (match-define (ring vec _) rb)
  (define l (vector-length vec))
  (cond
    [(>= idx l) (- idx l)]
    [else idx]))

(define/match (in-ring rb)
  [((ring vec last))
   #:when (nonnegative-integer? last)
   (define len (vector-length vec))
   (sequence-append
    (in-vector vec (add1 last) len)
    (in-vector vec 0 (add1 last)))])

(define/match (ring-first rb)
  [((ring vec last))
   #:when (nonnegative-integer? last)
   (vector-ref vec (ring-wrap rb (add1 last)))])

(define (ring-rest rb)
  (sequence-tail (in-ring rb) 1))

(define (ring-append rb what)
  (match rb
    [(ring vec last)
     (define next (ring-wrap rb (add1 last)))
     (vector-set! vec next what)
     (set-ring-last! rb next)]))

(define (solve1 input (distance 1000) (pick 64) #:stretcher (stretcher identity))
  ; make
  (define rb (make-ring distance))
  (define (append-hash i)
    (~> i
        number->string
        (string-append input _)
        string->bytes/latin-1
        md5
        stretcher
        (ring-append rb _)))
  ; and fill ring completely
  (for ([i (in-range distance)])
    (append-hash i))
  ; continue always checking the first element and adding after
  (let loop ([i distance]
             [last-found #f]
             [found 0])
    (cond
      [(= found pick) last-found]
      [else
       (define re
         (and~> rb
                ring-first
                (regexp-match #px#"(.)\\1{2}" _)
                second
                (bytes-ref 0)
                (make-bytes 5 _)
                byte-regexp))
       (define new-item
         (and re
              (for/or ([hash (ring-rest rb)])
                (regexp-match? re hash))))
       ; done with the first, this overwrites
       (append-hash i)
       (if new-item
           (loop (add1 i) (- i distance) (add1 found))
           (loop (add1 i) last-found found))])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (stretch str (repeat 2016))
  (for/fold ([acc str])
            ([_ (in-range repeat)])
    (md5 acc)))

(define (solve2 input)
  (solve1 input #:stretcher stretch))

(module+ main
  (printf "Part one: ~A~%" (solve1 (input)))
  (printf "Part two: ~A~%" (solve2 (input))))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "check consistency"
              (define foo (make-ring 4))
              (ring-append foo #"12")
              (ring-append foo #"34")
              (ring-append foo #"567")
              (ring-append foo #"89")
              (check-equal? (ring-first foo) #"12")
              (check-equal? (bytes-append* (sequence->list (in-ring foo))) #"123456789")
              (ring-append foo #"ab")
              (check-equal? (ring-first foo) #"34")
              (check-equal? (bytes-append* (sequence->list (in-ring foo))) #"3456789ab")
              (check-equal? (bytes-append* (sequence->list (ring-rest foo))) #"56789ab"))
   (test-case "Part 1"
              (check-equal? (md5 "abc0") #"577571be4de9dcce85a041ba0410f29f")
              (check-equal? (solve1 "abc") 22728)
              (check-equal? (solve1 (input)) 15168))
   (test-case "Part 2"
              (check-equal? (stretch "abc0" 2017) #"a107ff634856bb300138cac6568c0f24")
              (check-equal? (solve2 "abc") 22551)
              (check-equal? (solve2 (input)) 20864))))
