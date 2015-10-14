#lang racket/base

(provide (rename-out [colon-kw-read read]
                     [colon-kw-read-syntax read-syntax]
                     [colon-kw-get-info get-info]))

(require (only-in syntax/module-reader make-meta-reader)
         "../reader.rkt")

(define (wrap-reader reader)
  (define (rd . args)
    (parameterize ([current-readtable (make-colon-keyword-readtable)])
      (apply reader args)))
  rd)

(define-values (colon-kw-read colon-kw-read-syntax colon-kw-get-info)
  (make-meta-reader
   'colon-kw
   "language path"
   (lambda (bstr)
     (let* ([str (bytes->string/latin-1 bstr)]
            [sym (string->symbol str)])
       (and (module-path? sym)
            (vector
             ;; try submod first:
             `(submod ,sym reader)
             ;; fall back to /lang/reader:
             (string->symbol (string-append str "/lang/reader"))))))
   wrap-reader
   wrap-reader
   (lambda (proc)
     (lambda (key defval)
       (define (fallback) (if proc (proc key defval) defval))
       (case key
         [else (fallback)])))))

