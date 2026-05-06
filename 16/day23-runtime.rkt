#lang racket

(require threading)
(require (except-in "day12-runtime.rkt"
                    #%module-begin
                    run-program))

(define (add-to regs dst src)
  (~> dst
      (hash-ref regs _)
      (+ (hash-ref regs src))
      (hash-set regs dst _)
      (hash-set src 0)))

(define (mul-to regs dst op deplete)
  (define non-deplete (hash-ref regs op op))
  (~> non-deplete
      (list (hash-ref regs deplete))
      (foldl * 1 _)
      (+ (hash-ref regs dst))
      (hash-set regs dst _)
      (hash-set deplete 0)))

(define (run-program prg (regs #f))
  (define idata (list->vector (filter (negate void?) prg)))
  (define end (vector-length idata))
  (let loop ([pc 0]
             [regs (or regs (make-env))])
    (cond
      [(>= pc end) (hash-ref regs 'a)]
      [else
       (match (vector-ref idata pc)
         ; Handle toggle
         [(list 'toggle reg)
          (define distance (hash-ref regs reg))
          (define remote (+ pc distance))
          (when (< -1 remote end)
            (define new
              (match (vector-ref idata remote)
                [(list 'increment one-arg)
                 (list 'decrement one-arg)]
                [(list _ one-arg)
                 (list 'increment one-arg)]
                [(list 'jump-not-zero one two)
                 (list 'copy one two)]
                [(list _ one two)
                 (list 'jump-not-zero one two)]))
            (vector-set! idata remote new))
          (loop (add1 pc) regs)]
         ; Optimize jumps
         [(list 'jump-not-zero cnd dist)
          (define-values (advance-pc new-regs)
            (jump-not-zero regs cnd dist))
          (case pc
            [(7)
             (loop (add1 pc) (add-to new-regs 'a 'c))]
            [(15)
             (loop (add1 pc) (add-to new-regs 'c 'd))]
            [(23)
             (loop (add1 pc) (add-to new-regs 'a 'd))]
            [(9)
             (loop (add1 pc) (mul-to new-regs 'a 'b 'd))]
            [(28)
             (loop (add1 pc) (mul-to new-regs 'a 99 'c))]
            [else
             (loop (+ pc advance-pc) new-regs)])]
         ; Fallback to day 12
         [(list* instr args)
          (define-values (advance-pc new-regs)
            (apply (hash-ref mappings instr) regs args))
          (loop (+ pc advance-pc) new-regs)])])))

(define (solve prg eggs)
  (run-program prg (hash-set (make-env) 'a eggs)))

(define solve1 (curryr solve 7))
(define solve2 (curryr solve 12))

(define-syntax day23-module-begin
  (syntax-rules ()
    [(_ body)
     (#%module-begin
      (define program body)
      (define answer1 (solve1 program))
      (printf "Answer 1: ~A~%" answer1)
      (define answer2 (solve2 program))
      (printf "Answer 2: ~A~%" answer2)
      (require rackunit)
      (check-equal? answer1 14346)
      (check-equal? answer2 479010906))]))

(provide run-program
         (rename-out (day23-module-begin #%module-begin)))


#| Final state after last toggle:

01 copy a b
02 decrement b
03 copy a d
04 copy 0 a
05     copy b c
06         increment a
07         decrement c
08         jump-not-zero c -2 ; a += [c]
09     decrement d
11     jump-not-zero d -5 ; a += [d] * b
12 decrement b
13 copy b c
14 copy c d
15     decrement d
16     increment c
17     jump-not-zero d -2 ; c += [d]
18 toggle c
19 copy -16 c
21 copy 1 c
22 copy 94 c
23     copy 99 d
24         increment a
25         decrement d
26         jump-not-zero d -2 ; a += [d]
27     decrement c
28     jump-not-zero c -5 ; a += [c] * 99

|#
