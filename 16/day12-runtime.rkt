#lang debug racket

(define (make-env)
  (foldl (λ (c acc) (hash-set acc c 0)) (hasheq) '(a b c d)))

(define/contract (copy regs src dst)
  (hash? integer? symbol? . -> . any)
  (values 1 (hash-set regs dst src)))

(define/contract (increment regs register)
  (hash? symbol? . -> . any)
  (values 1 (hash-update regs register add1)))

(define/contract (decrement regs register)
  (hash? symbol? . -> . any)
  (values 1 (hash-update regs register sub1)))

(define/contract (jump-not-zero regs compare ahead)
  (hash? integer? integer? . -> . any)
  (values (if (zero? compare) 1 ahead) regs))

(define mappings (hasheq 'copy copy
                         'increment increment
                         'decrement decrement
                         'jump-not-zero jump-not-zero))

(define (do-read regs lst)
  (for/list ([e (in-list lst)])
    (cond
      [(and (list? e) (eq? (first e) 'read))
       (hash-ref regs (second e))]
      [else e])))

(define (run-program prg (env #f))
  (define idata (list->vector (filter (negate void?) prg)))
  (define end (vector-length idata))
  (let loop ([pc 0]
             [regs (or env (make-env))])
    (cond
      [(>= pc end) (hash-ref regs 'a)]
      [else
       (define cur (do-read regs (vector-ref idata pc)))
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
