#lang racket/base

(provide make-colon-kw-lexer)

(require racket/match)

(define (make-colon-kw-lexer orig-lexer)
  (if (procedure-arity-includes? orig-lexer 3)
      (λ (in offset mode)
        (match (peek-char in)
          [#\: (match-let*-values ([(_ _ initial-loc) (begin0 (port-next-location in) (read-char in))]
                                   [(text orig-type _ orig-start orig-end backup new-mode) (orig-lexer in offset mode)]
                                   [(type) (if (eq? orig-type 'symbol) 'hash-colon-keyword 'error)]
                                   [(start end) (if orig-start
                                                    (values (sub1 orig-start) orig-end)
                                                    (values initial-loc initial-loc))])
                 (values (prepend-colon text) type #f start end backup new-mode))]
          [_   (orig-lexer in offset mode)]))
      (λ (in)
        (match (peek-char in)
          [#\: (match-let*-values ([(_ _ initial-loc) (begin0 (port-next-location in) (read-char in))]
                                   [(text orig-type _ orig-start orig-end) (orig-lexer in)]
                                   [(type) (if (eq? orig-type 'symbol) 'hash-colon-keyword 'error)]
                                   [(start end) (if orig-start
                                                    (values (sub1 orig-start) orig-end)
                                                    (values initial-loc initial-loc))])
                 (values (prepend-colon text) type #f start end))]
          [_   (orig-lexer in)]))))

(define (prepend-colon str/eof)
  (if (eof-object? str/eof) ":"
      (string-append ":" str/eof)))
