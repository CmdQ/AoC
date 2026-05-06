#lang racket

(define (make-env)
  (foldl (λ (c acc) (hash-set acc c 0)) (hasheq) '(a b c d)))

(define (value-of thing env)
  (cond
    [(number? thing) thing]
    [(string? thing) (string->number thing)]
    [else (hash-ref env thing)]))

(define (copy regs src dst)
  (values 1 (hash-set regs dst (value-of src regs))))

(define (increment regs register)
  (values 1 (hash-update regs register add1)))

(define (decrement regs register)
  (values 1 (hash-update regs register sub1)))

(define (jump-not-zero regs compare ahead)
  (values (if (zero? (value-of compare regs)) 1 ahead) regs))

(define mappings (hasheq 'copy copy
                         'increment increment
                         'decrement decrement
                         'jump-not-zero jump-not-zero))

(define (run-program prg (env #f))
  (define idata (list->vector (filter (negate void?) prg)))
  (define end (vector-length idata))
  (let loop ([pc 0]
             [regs (or env (make-env))])
    (cond
      [(>= pc end) (hash-ref regs 'a)]
      [else
       (define cur (vector-ref idata pc))
       (define-values (advance-pc new-regs)
         (apply (hash-ref mappings (first cur)) regs (rest cur)))
       (loop (+ pc advance-pc) new-regs)])))

(define (solve1 prg)
  (run-program prg))

(define (solve2 prg)
  (run-program prg (hash-set (make-env) 'c 1)))

(define-syntax day12-module-begin
  (syntax-rules ()
    [(_ body)
     (#%module-begin
      (define program body)
      (define answer1 (solve1 program))
      (printf "Answer 1: ~A~%" answer1)
      (define answer2 (solve2 program))
      (printf "Answer 2: ~A~%" answer2)
      (require rackunit)
      (check-equal? answer1 317993)
      (check-equal? answer2 9227647))]))

(provide copy jump-not-zero increment decrement run-program
         (rename-out (day12-module-begin #%module-begin)))
