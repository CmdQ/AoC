#lang racket

(require threading)

(define input (~> "input7.txt"
                  file->lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 1

(define ((has-what? regex) str)
  (define matches (for/list ([m (regexp-match* regex
                                               str
                                               #:match-select (lambda~> (drop 1)))]
                             #:when (not (equal? (first m) (second m))))
                    m))
  (if (null? matches) #f matches))

(define has-abba? (has-what? #px"([[:alpha:]])([[:alpha:]])\\2\\1"))

(define (split addr)
  (define hypernets null)
  (define dashes (regexp-replace* #px"[[](\\w+)[]]"
                                  addr
                                  (λ (m chars)
                                    (set! hypernets (cons chars hypernets))
                                    "-")))
  (values dashes hypernets))

(define (supports-tls? addr)
  (define-values (supernet hypernets) (split addr))
  (and (has-abba? supernet)
       (not (memf has-abba? hypernets))))

(define (solve1 input)
  (count supports-tls? input))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Part 2

(define (has-aba? str)
  (let loop ([fst (string-ref str 0)]
             [snd (string-ref str 1)]
             [i 2]
             [acc null])
    (cond
      [(i . >= . (string-length str)) (if (null? acc) '(#f) acc)]
      [(and (equal? fst (string-ref str i)) (not (equal? fst snd)))
       (loop snd (string-ref str i) (add1 i) (cons (list fst snd) acc))]
      [else (loop snd (string-ref str i) (add1 i) acc)])))

(define (supports-ssl? addr)
  (define-values (supernet hypernets) (split addr))
  (for/or ([m (has-aba? supernet)])
    (match m
      [(list a b)
       (pair? (memf (λ (h) (string-contains? h (list->string (list b a b))))
                    hypernets))]
      [_ #f])))

(define (solve2 input)
  (count supports-ssl? input))

(module+ test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tests
  (require rackunit)

  (test-begin
   (check-equal? (last input)
                 "xuabbxdwkutpsogcfea[tgetfqpgstsxrokcemk]cbftstsldgcqbxf[vwjejomptmifhdulc]ejeroshnazbwjjzofbe")
   (test-case "Part 1"
              (for ([ex '("abba[mnop]qrst" "ioxxoj[asdfgh]zxcvbn")])
                (check-true (supports-tls? ex) ex))
              (for ([ex '("abcd[bddb]xyyx" "aaaa[qwer]tyui")])
                (check-false (supports-tls? ex)))
              (check-equal? (solve1 input) 105))
   (test-case "Part 2"
              (check-not-false (has-aba? "aaa-eke"))
              (for ([ex '("aba[bab]xyz" "aaa[kek]eke" "zazbz[bzb]cdb")])
                (check-true (supports-ssl? ex) ex))
              (check-false (supports-ssl? "xyx[xyx]xyx"))
              (check-equal? (solve2 input) 258))))
