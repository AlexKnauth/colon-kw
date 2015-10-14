#lang racket/base

(provide make-kw-colon-readtable)

(require racket/match)

(define (make-kw-colon-readtable [orig-rt (current-readtable)])
  (make-readtable orig-rt
    #f 'non-terminating-macro (make-kw-colon-proc orig-rt)))

(define (make-kw-colon-proc orig-rt)
  (define (proc c in src ln col pos)
    (define stx
      (read-syntax/recursive src in c orig-rt))
    (if (identifier? stx)
        (parse-id stx)
        stx))
  proc)

(define (parse-id stx)
  (define str (symbol->string (syntax-e stx)))
  (define len (string-length str))
  (if (and (positive? len) (char=? #\: (string-ref str (sub1 len))))
      (datum->syntax stx (string->keyword (substring str 0 (sub1 len))) stx stx)
      stx))

(module+ test
  (require rackunit)
  (define (reads in out)
    (check-equal? (read (open-input-string in)) out))
  (parameterize ([current-readtable (make-kw-colon-readtable)])
    (reads "a:b" 'a:b)
    (reads ":a" ':a)
    (reads "a:" '#:a)
    (reads "#:a" '#:a)))
