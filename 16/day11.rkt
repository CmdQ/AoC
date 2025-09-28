#lang debug racket

(require threading)
(require racket/treelist)

(define bottom-floor 1)
(define top-floor 4)

(define elements empty)
(define (parse port)
  (cond
    [(string? port)
     (cond
       [(file-exists? port)
        (call-with-input-file port parse #:mode 'text)]
       [else (parse (open-input-string port))])]
    [else
     (define input (make-immutable-hasheq
                    (append*
                     (for/list ([line (port->lines port)])
                       (for/list ([item (regexp-match*
                                         #px"\\w+(?: generator|-compatible microchip| cage)"
                                         line)])
                         (define replacer
                           (cond
                             [(string-suffix? item "cage")
                              (λ (item) (string-replace item " cage" ""))]
                             [(string-suffix? item "generator") ; length 9
                              (set! elements (cons (string->symbol
                                                    (substring item 0
                                                               (- (string-length item) 10)))
                                                   elements))
                              (λ (item) (string-replace item " " "-"))]
                             [else
                              (λ (item) (string-replace item "compatible " ""))]))
                         (define i (case (substring line 4 6)
                                     [("fi") bottom-floor]
                                     [("se") 2]
                                     [("th") 3]
                                     [("fo") top-floor]
                                     [else (error 'unreachable)]))
                         (cons (string->symbol (replacer item)) i))))))
     (hash-update input 'elevator identity 1)]))
(define input (parse "input11.txt"))
(set! elements (sort elements symbol<?))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define ((what-for what) element)
  (string->symbol (string-append (symbol->string element) what)))

(define generator-for (what-for "-generator"))
(define chip-for (what-for "-microchip"))

(define ((what-ref func) hash element)
  (hash-ref hash (func element) 0))

(define gen-floor (what-ref generator-for))
(define chip-floor (what-ref chip-for))

(define (danger? state)
  (for/or ([chip (in-list elements)]
           #:do ((define floor (chip-floor state chip))
                 (define safe (gen-floor state chip)))
           #:when (and (positive? floor) (not (= floor safe)))
           [generator (in-list elements)]
           #:when (not (eq? chip generator)))
    (define gf (gen-floor state generator))
    (and (positive? gf) (= floor gf))))

(define (done? state)
  (sequence-andmap (λ (e) (and (not (eq? e 'elevator))
                               (= (gen-floor state e) top-floor)
                               (= (chip-floor state e) top-floor))) elements))

(define/match (elevator-moves state)
  [((hash* ('elevator floor))) (elevator-moves floor)]
  [(floor)
   (filter (λ (i) (<= bottom-floor i top-floor))
           (map (λ (f) (f floor)) (list add1 sub1)))])

(define (stuff-on state floor)
  (~> state
      hash->list
      (filter-map (λ (pair) (if (and (= (cdr pair) floor)
                                     (not (eq? (car pair) 'elevator)))
                                (car pair)
                                #f)) _)))

(define (valid-moves state)
  (define from (hash-ref state 'elevator))
  (define items (stuff-on state from))
  (define thinkable (for*/treelist ([to-floor (elevator-moves from)]
                                    [combo (sequence-append (in-combinations items 1) (in-combinations items 2))])
                      (~> state
                          (foldl (λ (elm acc) (hash-set acc elm to-floor)) _ combo)
                          (hash-set 'elevator to-floor))))
  (treelist-filter (negate danger?) thinkable))

(define (solve1 state)
  (define visited (mutable-set))
  (let loop ([queue (treelist (cons state 0))])
    (match-define (cons current depth) (treelist-first queue))
    (cond
      [(set-member? visited current) (loop (treelist-rest queue))]
      [(done? current) depth]
      [else
       (set-add! visited current)
       (loop (treelist-append (treelist-rest queue) (treelist-map (valid-moves current) (lambda~> (cons (add1 depth))))))])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 state)
  (define new-elements '(elerium dilithium))
  (set! elements (sort (append '(elerium dilithium) elements) symbol<?))
  (~> new-elements
      (append-map (λ (s) (map (λ (f) (f s)) (list generator-for chip-for))) _)
      (foldl (λ (elm acc) (hash-set acc elm 1)) state _)
      solve1))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-equal? input #hasheq((promethium-generator . 1)
                               (promethium-microchip . 1)
                               (cobalt-generator . 2)
                               (curium-generator . 2)
                               (ruthenium-generator . 2)
                               (plutonium-generator . 2)
                               (cobalt-microchip . 3)
                               (curium-microchip . 3)
                               (ruthenium-microchip . 3)
                               (plutonium-microchip . 3)
                               (elevator . 1)))
   (test-case "Part 1"
              (check-equal? elements '(cobalt
                                       curium
                                       ;dilithium
                                       ;elerium
                                       plutonium
                                       promethium
                                       ruthenium))
              (test-case "Danger"
                         (check-true (danger? (parse "The third floor contains a promethium-compatible microchip and a cobalt generator.")))
                         (check-false (danger? (parse "The first promethium-compatible microchip.\nThe second cobalt generator.")))
                         (check-false (danger? (parse "The third floor contains a promethium-compatible microchip, promethium generator and a cobalt generator, elevator cage."))))
              (test-case "Elevator"
                         (check-equal? (elevator-moves input) '(2))
                         (check-equal? (sort (elevator-moves 3) <) '(2 4)))
              (test-case "What's on that floor?"
                         (check-equal? (stuff-on input top-floor) empty)
                         (check-equal? (stuff-on input 1) '(promethium-microchip promethium-generator)))
              (test-case "Generate valid moves"
                         (define single-moves
                           (~> '("The first cobalt generator.\nThe second cobalt-compatible microchip, curium-compatible microchip.\nThe third curium generator, plutonium generator, elevator cage."
                                 "The first cobalt generator, curium generator.\nThe second cobalt-compatible microchip, curium-compatible microchip.\nThe third plutonium generator."
                                 "The first cobalt generator, cobalt-compatible microchip.\nThe second curium generator, curium-compatible microchip.\nThe third plutonium generator.")
                               (map parse _)
                               list->set))
                         (define double-moves
                           (~> '("The first cobalt generator.\nThe second cobalt-compatible microchip.\nThe third curium generator, curium-compatible microchip, plutonium generator, elevator cage."
                                 "The first cobalt generator, curium generator, curium-compatible microchip, elevator cage.\nThe second cobalt-compatible microchip.\nThe third plutonium generator."
                                 "The first cobalt generator, cobalt-compatible microchip, curium generator, elevator cage.\nThe second curium-compatible microchip.\nThe third plutonium generator.")
                               (map parse _)
                               list->set))
                         (check-equal? (list->set (valid-moves (parse "The first cobalt generator.\nThe second cobalt-compatible microchip, curium generator, curium-compatible microchip, elevator cage.\nThe third plutonium generator.")))
                                       (set-union single-moves double-moves) "double doesn't work"))
              (check-false (done? input))
              (check-equal? (solve1 input) 33))
   (test-case "Part 2"
              (check-equal? (solve2 input) 33))))
