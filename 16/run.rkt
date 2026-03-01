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
  (define start (current-inexact-milliseconds))
  (thunk)
  (- (current-inexact-milliseconds) start))

(define (fmt-ms ms)
  (format "~a ms" (real->decimal-string (/ (round (* ms 10)) 10.0) 1)))

(define (load-module! f)
  (dynamic-require f #f))

(define (input-rkt f)
  (define name (regexp-replace #px"day(\\d+)\\.rkt$"
                               (path->string (file-name-from-path f))
                               "input\\1.rkt"))
  (build-path here name))

(define (run-main! f)
  (with-handlers ([exn:fail?
                   (λ (e)
                     (define alt (input-rkt f))
                     (if (file-exists? alt)
                         (measure (λ () (dynamic-require alt #f)))
                         (begin (printf "(no main)~%") #f)))])
    (measure (λ () (dynamic-require `(submod ,f main) #f)))))

(define files (day-files))

(define args (current-command-line-arguments))

(cond
  [(= (vector-length args) 1)
   (define n (string->number (vector-ref args 0)))
   (define f (findf (λ (f) (= (day-number f) n)) files))
   (if f
       (begin
         (load-module! f)
         (printf "(~a)~%" (fmt-ms (run-main! f))))
       (eprintf "Day ~a not found~%" n))]
  [else
   (printf "Loading ~a days... " (length files))
   (define load-ms (measure (λ () (for ([f files]) (load-module! f)))))
   (printf "(~a)~%~%" (fmt-ms load-ms))
   (for ([f files])
     (printf "=== Day ~a ===~%" (day-number f))
     (define t (run-main! f))
     (when t (printf "(~a)~%" (fmt-ms t)))
     (newline))])
