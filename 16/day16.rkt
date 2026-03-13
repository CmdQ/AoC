#lang racket

(require "utils.rkt")
(require threading)

(define input "10001110011110000")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(struct mirror-reversed (content) #:transparent)
(struct/contract capped ((content mirror-reversed?) (cap integer?)) #:transparent)

(define xor10 (hasheq #\0 #\1 #\1 #\0 #t #\1 #f #\0))

(define (get-char thing at)
  (match thing
    [(? string?)
     (string-ref thing at)]
    [(capped _ cap)
     #:when (>= at cap)
     (raise-arguments-error 'at
                            "access outside of capped range"
                            "capped at" cap
                            "accessed" at)]
    [(or (mirror-reversed content) (capped (mirror-reversed content) _))
     (define len (get-length content))
     (cond
       [(< at len)
        (get-char content at)]
       [(> at len)
        (hash-ref xor10 (get-char content (- (* 2 len) at)))]
       [else #\0])
     ]))

(define/match (get-length thing)
  [((? string?)) (string-length thing)]
  [((capped _ cap)) cap]
  [((mirror-reversed content))
   (add1 (* 2 (get-length content)))])

(define/match (xor-reverse thing)
  [((? string?))
   (define len (get-length thing))
   (build-string len (lambda~> (- len 1 _)
                               (get-char thing _)
                               (hash-ref xor10 _)))])

(define/match (step thing)
  [((? string?))
   (string-append thing "0" (xor-reverse thing))]
  [(_)
   (mirror-reversed thing)])

(define/match (mirror-reversed->sequence mr)
  [((mirror-reversed content))
   (define len (get-length content))
   (sequence-append (~> len
                        in-range
                        (sequence-map (curry get-char content) _))
                    (in-value #\0)
                    (~> len
                        in-range
                        (sequence-map add1 _)
                        (sequence-map (curry - len) _)
                        (sequence-map (curry get-char content) _)
                        (sequence-map (curry hash-ref xor10) _)))])

(define even-length-thing/c
  (make-flat-contract #:name 'even-length-string/c
                      #:first-order (λ (thing) (even? (get-length thing)))))

(define/contract (checksum-step thing)
  ((or/c even-length-thing/c capped?) . -> . string?)
  (match thing
    [(? string?)
     (build-string (quotient (get-length thing) 2)
                   (lambda~> (* 2)
                             ; Neat trick: using 2 parens makes this a call of that lambda,
                             ; since the threaded value becomes the first argument.
                             ((λ (pos) (hash-ref xor10 (eq? (get-char thing pos)
                                                            (get-char thing (add1 pos))))))))]
    [(capped mr cap)
     (define n (quotient cap 2))
     (define buf (make-string n))
     (for ([pair (in-slice 2 (mirror-reversed->sequence mr))]
           [i (in-range n)])
       (string-set! buf i (hash-ref xor10 (apply eq? pair))))
     buf]))

(define (checksum thing)
  (let loop ([acc thing])
    (cond
      [(even? (get-length acc))
       (loop (checksum-step acc))]
      [else acc])))

(define (solve input (required-length 272))
  (let loop ([acc input])
    (cond
      [(>= (get-length acc) required-length)
       (match acc
         [(? string?)
          (checksum (substring acc 0 required-length))]
         [(? mirror-reversed?)
          (checksum (capped acc required-length))])]
      [else
       (loop (step acc))])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (mirror-reversed->string mr)
  (~> mr
      mirror-reversed->sequence
      sequence->list
      list->string))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (test-case "checksums"
                         (check-equal? (checksum-step "110010110100") "110101")
                         (check-equal? (checksum-step "110101") "100")
                         (check-equal? (checksum "110010110100") "100"))
              (check-equal? (step "1") "100")
              (check-equal? (step "0") "001")
              (check-equal? (step "11111") "11111000000")
              (check-equal? (step "111100001010") "1111000010100101011110000")
              (check-equal? (solve "10000" 20) "01100"))
   (test-case "Part 2"
              ; directly to string
              (check-equal? (~> "11111"
                                mirror-reversed
                                mirror-reversed->sequence
                                sequence->list
                                list->string)
                            "11111000000")
              ; one level of struct
              (check-equal? (~> "100"
                                mirror-reversed
                                mirror-reversed
                                mirror-reversed->sequence
                                sequence->list
                                list->string)
                            "100011001001110")
              (check-equal? (mirror-reversed->string (mirror-reversed "111100001010"))
                            "1111000010100101011110000"))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve input) "10010101010011101"))
  (printf "Part two: ~A~%" (must-be (solve (mirror-reversed input) 35651584) "01100111101101111")))
