#lang debug racket

(require threading)
(require racket/treelist)

(define bottom-floor 1)
(define top-floor 4)

(define ((what-for what) element)
  (string->symbol (string-append (symbol->string element) what)))

(define generator-for (what-for "-generator"))
(define chip-for (what-for "-microchip"))

(define (vec2num input)
  (foldl (λ (elm acc) #R(bitwise-ior elm (arithmetic-shift acc 2))) 0 (vector->list input)))

(define (parse port)
  (cond
    [(string? port)
     (cond
       [(file-exists? port)
        (call-with-input-file port parse #:mode 'text)]
       [else (parse (open-input-string port))])]
    [else
     (define elements (mutable-set))
     (define state (append*
                    (for/list ([line (port->lines port)])
                      (for/list ([item (regexp-match*
                                        #px"\\w+(?: generator|-compatible microchip| cage)"
                                        line)])
                        (define replacer
                          (cond
                            [(string-suffix? item "cage")
                             (λ (item) (string-replace item " cage" ""))]
                            [(string-suffix? item "generator") ; length 9
                             (set-add! elements (string->symbol
                                                 (substring item 0
                                                            (- (string-length item) 10))))
                             (λ (item) (string-replace item " " "-"))]
                            [else
                             (set-add! elements (string->symbol
                                                 (substring item 0
                                                            (- (string-length item) 21))))
                             (λ (item) (string-replace item "compatible " ""))]))
                        
                        (define i (case (string-ref line 5)
                                    [(#\i) bottom-floor]
                                    [(#\e) 2]
                                    [(#\h) 3]
                                    [(#\o) top-floor]
                                    [else (error 'unreachable)]))
                        (cons (string->symbol (replacer item)) i)))))
     (set! elements ((compose list->vector set->list) elements))
     (vector-sort! elements symbol<?)
     (vec2num (for*/vector ([e elements]
                            [s (list generator-for chip-for)])
                (cdr (or (assoc (s e) state) (cons 0 0)))))]))

(define input (parse "input11.txt"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (danger? state)
  (define end (vector-length state))
  (for/or ([i (in-range 0 end 2)])
    (match-define
      (list g c)
      (~> '(0 1)
          (map (lambda~> (+ i)) _)
          (map (lambda~> (vector-ref state _)) _)))
    (and (positive? c) ; no chip cannot be fried
         (not (= c g)) ; but it's safe with its generator
         (for/or ([j (in-range 0 end 2)] #:when (not (= i j)))
           (= c (vector-ref state j))))))

(define (done? state)
  (for/and ([t (in-vector state)])
    (= t 4)))

(define (valid-moves-to state floor to)
  ;   g m  g m  g m  g m  g m
  ;   0 1  2 3  4 5  6 7  8 9
  ; #(2 3  2 3  2 3  1 1  2 3)
  (define len (vector-length state))
  (define single-moves
    (for/fold ([acc empty-treelist])
              ([i (in-range len)])
      (cond
        [(= (vector-ref state i) floor)
         (treelist-add acc (vector-set/copy state i to))]
        [else acc])))
  (define double-moves
    (for*/fold ([acc empty-treelist])
               ([i (in-range len)]
                [j (in-range (add1 i) len)]) ; TODO have start at same position and get single moves for free?
      (cond
        [(= (vector-ref state i) (vector-ref state j) floor)
         (define copy (vector-copy state))
         (vector-set! copy i to)
         (vector-set! copy j to)
         (treelist-add acc copy)]
        [else acc])))
  (cons to (treelist-filter (negate danger?) (treelist-append single-moves double-moves))))

(define (valid-moves state floor)
  (map (λ (to) (valid-moves-to state floor to)) (filter (lambda~> (<= 1 _ 4)) (list (add1 floor) (sub1 floor)))))

(define (solve1 state)
  (define visited (mutable-set))
  (let loop ([queue (treelist (list state 1 0))])
    (match-define (list current floor depth) (treelist-first queue))
    (cond
      [(set-member? visited (cons current floor)) (loop (treelist-rest queue))]
      [(done? current) depth]
      [else
       (set-add! visited (cons current floor))
       (~> (valid-moves current floor)
           (map (match-lambda [(cons elevator states)
                               (treelist-map states (lambda~> (list elevator (add1 depth))))])
                _)
           (apply treelist-append (treelist-rest queue) _)
           loop)])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 state)
  (define new-elements '(elerium dilithium))
  (~> new-elements
      length
      (* 2)
      (make-vector 1)
      (vector-append state _)
      solve1))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  ; 4 .  .   .   .   .   .   .   .   .    .   . 
  ; 3 .  .  CoM  .  CuM  .  PlM  .   .    .  RuG
  ; 2 . CoG  .  CuG  .  PlG  .   .   .   RuG  . 
  ; 1 E  .   .   .   .   .   .  PrG PrM   .   . 

  (require rackunit)

  (test-begin
   (check-equal? input #xBBB5B)
   (test-case "Part 1"
              (check-false (done? input))
              (test-case "Valid moves"
                         (check-equal? (~> (valid-moves input 1) cdar treelist->list list->set)
                                       (set #(2 3 2 3 2 3 2 2 2 3)
                                            #(2 3 2 3 2 3 2 1 2 3)))
                         (define many (valid-moves input 3))
                         (check-equal? (~> many cdar treelist->list list->set)
                                       ;    #(2 3 2 3 2 3 1 1 2 3)
                                       (set #(2 4 2 3 2 3 1 1 2 3)
                                            #(2 3 2 4 2 3 1 1 2 3)
                                            #(2 3 2 3 2 4 1 1 2 3)
                                            #(2 3 2 3 2 3 1 1 2 4)
                                            #(2 4 2 4 2 3 1 1 2 3)
                                            #(2 4 2 3 2 4 1 1 2 3)
                                            #(2 4 2 3 2 3 1 1 2 4)
                                            #(2 3 2 4 2 4 1 1 2 3)
                                            #(2 3 2 4 2 3 1 1 2 4)
                                            #(2 3 2 3 2 4 1 1 2 4)))
                         (check-equal? (~> many cdadr treelist->list list->set)
                                       ;    #(2 3 2 3 2 3 1 1 2 3)
                                       (set #(2 2 2 3 2 3 1 1 2 3)
                                            #(2 3 2 2 2 3 1 1 2 3)
                                            #(2 3 2 3 2 2 1 1 2 3)
                                            #(2 3 2 3 2 3 1 1 2 2)
                                            #(2 2 2 2 2 3 1 1 2 3)
                                            #(2 2 2 3 2 2 1 1 2 3)
                                            #(2 2 2 3 2 3 1 1 2 2)
                                            #(2 3 2 2 2 2 1 1 2 3)
                                            #(2 3 2 2 2 3 1 1 2 2)
                                            #(2 3 2 3 2 2 1 1 2 2))))
              (check-equal? (first (valid-moves input 1)) (valid-moves-to input 1 2))
              (check-equal? (solve1 input) 33))
   (test-case "Part 2"
              (check-equal? (solve2 input) 57))))
