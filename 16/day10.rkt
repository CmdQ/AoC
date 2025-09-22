#lang racket

(require threading)

(require "utils.rkt")

(struct/contract recipient ((id integer?) (type symbol?)) #:transparent)
(define (make-recipient) (recipient -1 'unknown))
(struct/contract bot ((chips (listof integer?)) (low-to recipient?) (high-to recipient?)) #:transparent)
(define (make-bot) (bot '() (make-recipient) (make-recipient)))
(define/contract (bot-add-chip b value)
  (bot? integer? . -> . bot?)
  (bot (cons value (bot-chips b)) (bot-low-to b) (bot-high-to b)))
(struct/contract world ((bots (hash/c integer? bot?)) (outputs (hash/c integer? integer?))) #:transparent)

(define input
  (let ([bots (make-hash)])
    (~> "input10.txt"
        file->lines
        (for-each (match-lambda
                    [(pregexp #px"bot (\\d+) gives low to (bot|output) (\\d+) and high to (bot|output) (\\d+)" (list _ from low-type low-id high-type high-id))
                     (shadow-as ([string->number from low-id high-id])
                       (hash-update! bots
                                     from
                                     (λ (b) (bot
                                             (bot-chips b)
                                             (recipient low-id (string->symbol low-type))
                                             (recipient high-id (string->symbol high-type))))
                                     (make-bot)))
                     ]
                    [(pregexp #px"value (\\d+) goes to bot (\\d+)" (list _ value id))
                     (shadow-as ([string->number value id])
                       (hash-update! bots
                                   id
                                   (lambda~> (bot-add-chip value))
                                   (make-bot)))])
                  _))
    (world bots (make-hash))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define (solve1 input)
  (define which #f)
  (define bots (world-bots input))
  (define (to-bot! id value)
    (hash-update! bots id (lambda~> (bot-add-chip value))))
  (define outs (world-outputs input))
  (let loop ()
    (define updates (flatten (for/list ([(k v) (in-hash bots)])
                               (match v
                                 [(bot (list x y) to-low to-high)
                                  (define ordered (if (< x y) (list x y) (list y x)))
                                  (when (equal? ordered '(17 61))
                                    (set! which k))
                                  (for/list ([r (list to-low to-high)]
                                             [choice ordered])
                                    (list
                                     (λ () (hash-set! bots k (bot '() to-low to-high)))
                                     (match-let ([(recipient id type) r])
                                       (case type
                                         ['bot
                                          (λ () (to-bot! id choice))]
                                         ['output
                                          (λ () (hash-set! outs id choice))]
                                         [else (error 'impossible)]))))]
                                 [_ null]))))

    (cond
      [(null? updates) which]
      [else
       (for-each (λ (f) (f)) updates)
       (loop)])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (solve2 input)
  (~> '(0 1 2)
      (map (lambda~> (hash-ref (world-outputs input) _)) _)
      (apply * _)))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (test-case "Part 1"
              (check-equal? (solve1 input) 47))
   (test-case "Part 2"
              (check-equal? (solve2 input) 2666))))
