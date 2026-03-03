#lang racket

(define here (path-only (path->complete-path (find-system-path 'run-file))))

(define (day-files)
  (sort
   (filter (λ (p) (regexp-match? #px"^day\\d{2}\\.rkt$"
                                 (path->string (file-name-from-path p))))
           (directory-list here #:build? #t))
   path<?))

(define (day-number path)
  (string->number (car (regexp-match #px"\\d+" (path->string (file-name-from-path path))))))

(define (measure thunk)
  (collect-garbage)
  (define mem-before (current-memory-use))
  (define start (current-inexact-milliseconds))
  (thunk)
  (values (- (current-inexact-milliseconds) start)
          (max 0 (- (current-memory-use) mem-before))))

(define (fmt-ms ms)
  (format "~a ms" (real->decimal-string (/ (round (* ms 10)) 10.0) 1)))

(define (fmt-bytes b)
  (cond
    [(< b 1024)           (format "~a B"  b)]
    [(< b (* 1024 1024))  (format "~a KB" (real->decimal-string (/ b 1024.0) 1))]
    [else                 (format "~a MB" (real->decimal-string (/ b 1024.0 1024.0) 1))]))

(define (load-module! f)
  (dynamic-require f #f))

(define (input-rkt f)
  (define name (regexp-replace #px"day(\\d+)\\.rkt$"
                               (path->string (file-name-from-path f))
                               "input\\1.rkt"))
  (build-path here name))

; Returns (list time-ms mem-bytes) or #f
(define (run-main! f)
  (with-handlers ([exn:fail?
                   (λ (e)
                     (define alt (input-rkt f))
                     (if (file-exists? alt)
                         (let-values ([(t m) (measure (λ () (dynamic-require alt #f)))])
                           (list t m))
                         (begin (printf "(no main)~%") #f)))])
    (let-values ([(t m) (measure (λ () (dynamic-require `(submod ,f main) #f)))])
      (list t m))))

(define (bar-chart results)
  (define bar-width 40)
  (define valid (filter cdr results))
  (define max-ms (apply max (map (λ (r) (first (cdr r))) valid)))
  (define time-strs (map (λ (r) (if (cdr r) (fmt-ms (first (cdr r))) "no main")) results))
  (define mem-strs  (map (λ (r) (if (cdr r) (fmt-bytes (second (cdr r))) "")) results))
  (define max-time-w (apply max (map string-length time-strs)))
  (define max-mem-w  (apply max (map string-length mem-strs)))
  (printf "~%--- Timing ---~%")
  (for ([r results] [time-str time-strs] [mem-str mem-strs])
    (define day (car r))
    (define result (cdr r))
    (define ms (and result (first result)))
    (define filled (if ms (inexact->exact (round (* bar-width (/ ms max-ms)))) 0))
    (define label (format "Day ~a" (~a day #:min-width 2)))
    (define bar (if ms
                    (string-append (make-string filled #\█) (make-string (- bar-width filled) #\░))
                    (make-string bar-width #\space)))
    (printf "~a |~a| ~a  ~a~%"
            label bar
            (~a time-str #:min-width max-time-w #:align 'right)
            (~a mem-str  #:min-width max-mem-w  #:align 'right))))

(define all-files (day-files))
(define args (current-command-line-arguments))

(define selected-files
  (if (zero? (vector-length args))
      all-files
      (filter-map (λ (n)
                    (findf (λ (f) (= (day-number f) n)) all-files))
                  (map string->number (vector->list args)))))

(define single? (= (vector-length args) 1))

(printf "Loading ~a day~a... " (length selected-files) (if single? "" "s"))
(define-values (load-ms load-mem) (measure (λ () (for ([f selected-files]) (load-module! f)))))
(printf "(~a, ~a)~%~%" (fmt-ms load-ms) (fmt-bytes load-mem))

(define results
  (for/list ([f selected-files])
    (printf "=== Day ~a ===~%" (day-number f))
    (define result (run-main! f))
    (when result (printf "(~a, ~a)~%" (fmt-ms (first result)) (fmt-bytes (second result))))
    (newline)
    (cons (day-number f) result)))

(unless single?
  (bar-chart results))
