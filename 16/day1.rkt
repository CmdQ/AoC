#lang racket

(require threading)

(define input (~> "input1.txt"
                  file->string
                  string-trim
                  (string-split ", ")
                  (map (lambda (instr) (cons (string-ref instr 0)
                                             (~> instr
                                                 (substring 1)
                                                 string->number))) _)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define/contract (turn orientation direction)
  (-> complex? char? complex?)
  (* orientation (case direction
                   [(#\L) 0+1i]
                   [(#\R) 0-1i])))

(define (endpoints)
  (for/fold ([pos 0]
             [dir 0+1i])
            ([instr (in-list input)])
    (define dist (cdr instr))
    (define ndir (turn dir (car instr)))
    (values (+ pos (* dist ndir)) ndir)))

(define/contract (manhatten pos)
  (-> complex? real?)
  (+ (abs (real-part pos)) (abs (imag-part pos))))

(define (solve1)
  (define-values (pos _) (endpoints))
  (manhatten pos))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (draw-line pos dir dist seen)
  (when (set-member? seen pos)
    (raise (seen-already pos)))
  (cond
    [(zero? dist) seen]
    [else
     (draw-line (+ pos dir) dir (sub1 dist) (set-add seen pos))]))

(struct seen-already (pos) #:transparent)

(define (allpoints input)
  (with-handlers ([seen-already? (lambda (e) (seen-already-pos e))])
    (for/fold ([pos 0]
               [dir 0+1i]
               [seen (set)])
              ([instr (in-list input)])
      (define ndir (turn dir (car instr)))
      (values (+ pos (* (cdr instr) ndir))
              ndir
              (draw-line pos ndir (cdr instr) seen)))))

(define (solve2 input)
  (define pos (allpoints input))
  (manhatten pos))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)
  
  (check-eq? (turn 0+1i #\L) -1)
  (check-eq? (turn 0+1i #\R) 1)

  (check-eq? (solve1) 209)

  (check-eq? (solve2 '((#\R . 8) (#\R . 4) (#\R . 4) (#\R . 8))) 4)
  (check-eq? (solve2 input) 136))
