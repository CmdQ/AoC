#lang racket

#|
You'd like to set up a small hidden computer here so you can use it to
get back into the network later. However, the corporate firewall only
allows communication with certain external IP addresses.

You've retrieved the list of blocked IPs from the firewall, but the list
seems to be messy and poorly maintained, and it's not clear which IPs
are allowed. Also, rather than being written in dot-decimal notation,
they are written as plain 32-bit integers, which can have any value from
0 through 4294967295, inclusive.

For example, suppose only the values 0 through 9 were valid, and that
you retrieved the following blacklist:

5-8
0-2
4-7

The blacklist specifies ranges of IPs (inclusive of both the start and
end value) that are not allowed. Then, the only IPs that this firewall
allows are 3 and 9, since those are the only numbers not in any range.

Given the list of blocked IPs you retrieved from the firewall (your
puzzle input), what is the lowest-valued IP that is not blocked?
|#

(require "utils.rkt")
(require threading)

(struct interval (lo hi) #:transparent)
(define (make-interval lo hi)
  (when (> lo hi)
    (raise-arguments-error 'make-interval
                           "interval is inverted"
                           "lo" lo
                           "hi" hi))
  (interval lo hi))

(define input (~> "input20.txt"
                  file->lines
                  (map (λ (line)
                         (define dash (string-find line "-"))
                         (~> (list (list 0 dash)
                                   (list (add1 dash)))
                             (map (lambda~> (apply substring line _)) _)
                             (map string->number _)
                             (apply make-interval _)))
                       _)))
(define upper-bound 4294967295)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(struct payload (interval max) #:transparent)
(define make-payload
  (case-lambda
    [(iv) (payload iv (interval-hi iv))]
    [(l h) (payload (make-interval l h) h)]))

(struct tree-node (left val right) #:transparent)
(define-match-expander N
  (syntax-rules () [(_ l v r) (tree-node l v r)])
  (syntax-rules () [(_ l v r) (tree-node l v r)]))
(define-match-expander L
  (syntax-rules () [(_) (? not)])
  (syntax-rules () [(_) #f]))
(define-match-expander P
  (syntax-rules () [(_ lo hi mx) (payload (interval lo hi) mx)]))

(define (insert tree intv)
  (match tree
    [(L) (N (L) (make-payload intv) (L))]
    [(N l (and (P p-lo p-hi mx) p) r)
     (define new-lo (interval-lo intv))
     (cond
       ; First check for overlap.
       [(and (>= new-lo p-lo) (<= (interval-hi intv) p-hi))
        tree]
       ; Descend left.
       [(< new-lo p-lo)
        (define inserted (insert l intv))
        (match inserted
          [(N _ (payload low-intv low-mx) _)
           (N inserted (payload (make-interval p-lo p-hi) (max mx low-mx)) r)])]
       ; Descend right.
       [(> new-lo p-lo)
        (define inserted (insert r intv))
        (match inserted
          [(N _ (payload low-intv low-mx) _)
           (N l (payload (make-interval p-lo p-hi) (max mx low-mx)) inserted)])]
       ; Safeguard.
       [else (assert-unreachable)])]))

(define input-tree (foldl (flip insert) (L) input))

(define (solve1 input)
  (let/ec return
    (let loop ([tree input]
               [highest-so-far -1])
      (match tree
        [(L) highest-so-far]
        [(N l (P lo hi mx) r)
         (define highest-from-left (loop l highest-so-far))
         (when (> lo (add1 highest-from-left))
           (return (add1 highest-from-left)))
         (loop r (max highest-from-left hi))]))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (define-values (count ceiling)
    (let loop ([input input]
               [ceiling -1])
      (match input
        [(L) (values 0 ceiling)]
        [(N l (P lo hi mx) r)
         (define-values (sum-left ceiling-left) (loop l ceiling))
         (define-values (sum-right ceiling-right) (loop r (max hi ceiling-left)))
         (values (+ sum-left
                    (max 0 (- lo (add1 ceiling-left)))
                    sum-right)
                 ceiling-right)])))
  (+ count (- upper-bound ceiling)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (check-equal? (last input) (make-interval 2378537309 2380543166))

  (define example (~> '((5 8) (0 2) (4 7))
                      (map (lambda~> (apply make-interval _)) _)))
  (define example-tree (foldl (λ (elm acc) (insert acc elm)) (L) example))

  (test-begin
   (test-case "Part 1"
              (check-equal? (solve1 example-tree) 3))))

(module+ main
  (printf "Part one: ~A~%" (must-be (solve1 input-tree) 4793564))
  (printf "Part two: ~A~%" (must-be (solve2 input-tree) 146)))
