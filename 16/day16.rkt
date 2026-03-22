#lang racket

(require "utils.rkt")
(require threading)

(define input #b10001110011110000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(struct/contract nint ((number integer?)
                       (bits nonnegative-integer?))
                 #:transparent)

(define (make-nint num)
  (nint num (integer-length num)))

(struct mirror-reversed (content) #:transparent)
(struct/contract capped ((content mirror-reversed?) (cap integer?)) #:transparent)

(define (create-alternating-mask freq len)
  (let loop ([n (~> freq
                    (arithmetic-shift 1 _)
                    sub1)]
             ; Leading 0s count too.
             [cur (* 2 freq)])
    (cond
      [(>= cur len) n]
      [else
       (loop (bitwise-ior n (arithmetic-shift n cur)) (* 2 cur))])))

(define/match (checksum-step num)
  [((nint n len))
   #:when (even? len)
   (let loop ([shift-by 1]
              [acc n])
     (cond
       [(>= shift-by len) (nint acc (quotient len 2))]
       [else
        (define masked (bitwise-and (create-alternating-mask shift-by len) acc))
        (loop (arithmetic-shift shift-by 1)
              (bitwise-ior masked (arithmetic-shift masked (- shift-by))))]))])

(define (xnor-step n len)
  (define xored (bitwise-xor n (arithmetic-shift n -1)))
  (define width-mask (sub1 (arithmetic-shift 1 len)))
  (nint (bitwise-xor xored width-mask) len))

(define/match (checksum thing)
  [((nint n len))
   #:when (even? len)
   (checksum (checksum-step (xnor-step n len)))]
  [(_) (->string thing)])

(define/match (->string mr)
  [((nint num bits))
   (define s (format "~B" num))
   (string-append (make-string (max 0 (- bits (string-length s))) #\0) s)]
  [((mirror-reversed content))
   (define forward (~> content ->string))
   (define sl (string-length forward))
   (string-append forward
                  "0"
                  (build-string sl (lambda~> (- sl 1 _)
                                             (string-ref forward _)
                                             ((λ (c) (if (char=? c #\0) #\1 #\0))))))])

(define (reverse-bits num width)
  ; Round width up to next power of 2 for SWAR
  (define pad (arithmetic-shift 1 (integer-length (sub1 width))))
  (define pad-mask (sub1 (arithmetic-shift 1 pad)))
  ; Left-align num in pad bits, then SWAR-reverse, then extract bottom width bits
  (let loop ([x (arithmetic-shift num (- pad width))]
             [step 1])
    (if (>= step pad)
        (bitwise-and x (sub1 (arithmetic-shift 1 width)))
        (let ([mask (bitwise-and (create-alternating-mask step pad) pad-mask)])
          (loop (bitwise-and
                 (bitwise-ior (arithmetic-shift (bitwise-and x mask) step)
                              (bitwise-and (arithmetic-shift x (- step)) mask))
                 pad-mask)
                (* 2 step))))))

(define/match (->nint mr)
  [((mirror-reversed content))
   (match-define (nint forward half) (->nint content))
   (nint (bitwise-ior (arithmetic-shift forward (add1 half))
                      (bitwise-xor (reverse-bits forward half)
                                   (sub1 (arithmetic-shift 1 half))))
         (add1 (* 2 half)))]
  [(_) mr])

(define/match (get-length thing)
  [((nint _ len)) len]
  [((capped _ cap)) cap]
  [((mirror-reversed content))
   (add1 (* 2 (get-length content)))])

(define (solve input (required-length 272))
  (match input
    [(? integer?) (solve (make-nint input) required-length)]
    [(? nint?) (solve (mirror-reversed input) required-length)]
    [_
     (define len (get-length input))
     (cond
       [(< len required-length)
        (solve (mirror-reversed input) required-length)]
       [else
        (match-define (nint bigger longer) (->nint input))
        (checksum (nint (arithmetic-shift bigger (- required-length len)) required-length))])]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (test-case "checksum-step"
                         (check-equal? (checksum-step (xnor-step #b110010110100 12)) (nint #b110101 6))
                         (check-equal? (checksum-step (xnor-step #b110101 6)) (nint #b100 3)))
              (test-case "checksum"
                         (check-equal? (checksum (make-nint #b110010110100)) "100"))
              (test-case "->string dragon steps"
                         (check-equal? (->string (mirror-reversed (nint 1 1))) "100")
                         (check-equal? (->string (mirror-reversed (nint 0 1))) "001")
                         (check-equal? (->string (mirror-reversed (make-nint #b11111))) "11111000000")
                         (check-equal? (->string (mirror-reversed (make-nint #b111100001010))) "1111000010100101011110000"))
              (test-case "solve"
                         (check-equal? (solve #b10000 20) "01100")))
   (test-case "Part 2"
              (test-case "->nint"
                         (check-equal? (->nint (mirror-reversed (make-nint #b11111)))
                                       (nint #b11111000000 11))
                         (check-equal? (->nint (mirror-reversed (make-nint #b111100001010)))
                                       (nint #b1111000010100101011110000 25))))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve input) "10010101010011101"))
  (printf "Part two: ~A~%" (must-be (solve input 35651584) "01100111101101111")))
