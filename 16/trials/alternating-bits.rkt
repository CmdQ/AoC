#lang racket

(require threading)

(struct/contract nint ((number integer?)
                       (bits nonnegative-integer?))
                 #:transparent)

(define (make-nint num)
  (nint num (integer-length num)))

(define a #b110010110100)
(define b (make-nint a))

(define/match (checksum num)
  [((? integer?)) (checksum (make-nint num))]
  [((nint n len))
   #:when (odd? len)
   (raise-arguments-error 'checksum
                          "input has odd length"
                          "n" (format "~B" n)
                          "length" len)]
  [((nint n len))
   (let loop ([keep 1]
              [acc n])
     (define mask (sub1 (arithmetic-shift 1 keep)))
     (define keep-left (arithmetic-shift (bitwise-and acc (bitwise-not mask)) -2))
     (define keep-right (bitwise-and mask acc))
     (define new-acc (bitwise-ior
                      (arithmetic-shift keep-left 1)
                      keep-right))
     (cond
       [(or (>= keep len) (zero? keep-left)) new-acc]
       [else (loop (add1 keep) new-acc)]))])

(define (create-alternating-mask freq len)
  (let loop ([n (~> freq
                    (arithmetic-shift 1 _)
                    sub1)])
    (cond
      [(>= (integer-length n) len) n]
      [else
       ; Combine with a copy shifted by twive the freq (gets us the zeros).
       (loop (bitwise-ior n (arithmetic-shift n (arithmetic-shift freq 1))))])))

#| Have an input like
?a ?b ?c ?d ?e ?f ?g ?h
where I don't care about the question mark bits.

In the first iteration, I want to:
- shift everything to the right by 1
- or it with the original while
  - keeping the last 1 bit of the original and
  - all question marks are 0s, i.e. do nothing

     ?a?b?c?d?e?f?g?h
mask 0101010101010101
=    0a0b0c0d0e0f0g0h
or    0a0b0c0d0e0f0g0
=     aabbccddeeffggh
mask  ?ab??cd??ef??gh

In the second iteration, I want to:
- shift everything to the right by 2
- or it with the previous while
  - keeping the last 2 bits of the previous and
  - ? is 0

     ??ab??cd??ef??gh
mask 0011001100110011
=    00ab00cd00ef00gh
or     00ab00cd00ef00
=      ababcdcdefefgh
mask   ??abcd????efgh
|#
(define/match (checksum-big num)
  [((nint n len))
   #:when (even? len)
   (let loop ([shift-by 1]
              [acc n])
     (cond
       [(>= shift-by len) acc]
       [else
        (define masked (bitwise-and (create-alternating-mask shift-by len) acc))
        (loop (arithmetic-shift shift-by 1)
              (bitwise-ior masked (arithmetic-shift masked (- shift-by))))]))])

;;; Prepare an nint for checksum: compute XNOR of adjacent bits.
(define (xnor-step n len)
  (define xored (bitwise-xor n (arithmetic-shift n -1)))
  (define width-mask (sub1 (arithmetic-shift 1 len)))
  (nint (bitwise-xor xored width-mask) len))

(module+ test
  (require rackunit)

  (test-case "single step — AoC example"
             ; "110010110100" → checksum-step → "110101"
             (define ni (xnor-step #b110010110100 12))
             (check-equal? (checksum     ni) #b110101)
             (check-equal? (checksum-big ni) #b110101))

  (test-case "primitive = fast on various sizes"
             (for ([n (list #b110010110100
                            #b11001011010011001011010011001011   ; 32 bits
                            #b10101010101010101010101010101010   ; 32 bits alternating
                            (sub1 (arithmetic-shift 1 128))     ; 128 ones
                            (arithmetic-shift #b11001011 100))]); sparse bits
               (define len (integer-length n))
               (when (even? len)
                 (define ni (xnor-step n len))
                 (check-equal? (checksum ni) (checksum-big ni)
                               (format "mismatch for ~B" n))))))

(module+ main
  (define bits 50000)
  (define big-n (bitwise-xor (sub1 (arithmetic-shift 1 bits))
                             (arithmetic-shift #b10110010 (* bits 1/4))))
  (define big-ni (xnor-step big-n bits))
  (printf "~A bits — primitive: " bits)
  (define t0 (current-inexact-milliseconds))
  (define r1 (checksum big-ni))
  (define t1 (current-inexact-milliseconds))
  (define r2 (checksum-big big-ni))
  (define t2 (current-inexact-milliseconds))
  (printf "~A ms,  fast: ~A ms~%" (~r (- t1 t0) #:precision 1)
          (~r (- t2 t1) #:precision 1))
  (printf "results match: ~A~%" (equal? r1 r2)))