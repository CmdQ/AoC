#lang racket/base

(require racket/vector)
(require racket/match)
(require racket/function)
(require racket/contract)
(require racket/sequence)

(provide (contract-out
          [ring-buffer? (any/c . -> . boolean?)]
          [make-ring-buffer (exact-positive-integer? . -> . ring-buffer?)]
          [rename length ring-buffer-length (ring-buffer? . -> . exact-nonnegative-integer?)]
          [rename empty? ring-buffer-empty? (ring-buffer? . -> . boolean?)]
          [rename full? ring-buffer-full? (ring-buffer? . -> . boolean?)]
          [rename append ring-buffer-append (ring-buffer? any/c . -> . void?)]
          [rename ref ring-buffer-ref (ring-buffer? exact-nonnegative-integer? . -> . any/c)]
          [rename in in-ring-buffer (ring-buffer? . -> . sequence?)]
          [rename ->list ring-buffer->list (ring-buffer? . -> . list?)]))

(struct ring-buffer (data start count) #:mutable)

(define (make-ring-buffer size)
  (ring-buffer (make-vector size) 0 0))

(define (length buffer)
  (ring-buffer-count buffer))

(define (empty? buffer)
  (zero? (length buffer)))

(define (capacity buffer)
  (vector-length (ring-buffer-data buffer)))

(define (full? buffer)
  (= (capacity buffer)
     (ring-buffer-count buffer)))

(define (append buffer element)
  (match-define (ring-buffer data start count) buffer)
  (define cap (capacity buffer))
  (define (wrap idx) (modulo idx cap))
  (cond
    [(< count cap)
     (vector-set! data (wrap (+ start count)) element)
     (set-ring-buffer-count! buffer (add1 count))]
    [else
     (vector-set! data start element)
     (set-ring-buffer-start! buffer (wrap (add1 start)))]))

(define (warp-index buffer idx)
  (match-define (ring-buffer data start count) buffer)
  (when (not (< -1 idx count))
    (raise-range-error 'ring-buffer-ref
                       "ring buffer"
                       ""
                       idx
                       buffer
                       0 (sub1 count)))
  (modulo (+ start idx) (vector-length data)))

(define (delete! buffer pos)
  (match-define (ring-buffer _ start count) buffer)
  (cond
    [(zero? pos)
     (set-ring-buffer-start! buffer (warp-index buffer 1))
     (set-ring-buffer-count! buffer (sub1 count))]
    [else (assert-unreachable)]))

(define (ref buffer idx)
  (match-define (ring-buffer data start _) buffer)
  (vector-ref data (warp-index buffer idx)))

(define (in buffer)
  (define len (length buffer))
  (make-do-sequence (λ ()
                      (initiate-sequence
                       #:pos->element (curry ref buffer)
                       #:next-pos add1
                       #:init-pos 0
                       #:continue-with-pos? (curryr < len)))))

(define ->list (compose1 sequence->list in))

(module+ test
  (require rackunit)

  (define fill-to-3 (make-ring-buffer 3))
  (define full1 (make-ring-buffer 1))
  (append full1 42)

  (check-equal? (length fill-to-3) 0)
  (check-true (empty? fill-to-3))
  (check-false (full? fill-to-3))
  (check-true (full? full1))
  (append fill-to-3 10)
  (check-equal? (length fill-to-3) 1)
  (check-equal? (->list fill-to-3) '(10))
  (append fill-to-3 11)
  (check-equal? (length fill-to-3) 2)
  (check-equal? (->list fill-to-3) '(10 11))
  (append fill-to-3 12)
  (check-equal? (length fill-to-3) 3)
  (check-equal? (->list fill-to-3) '(10 11 12))
  (check-exn exn:fail:contract? (thunk (ref fill-to-3 -1)))
  (check-exn exn:fail:contract? (thunk (ref fill-to-3 4)))
  (append fill-to-3 13)
  (check-equal? (length fill-to-3) 3)
  (check-equal? (->list fill-to-3) '(11 12 13))
  (delete! fill-to-3 0)
  (check-equal? (->list fill-to-3) '(12 13)))