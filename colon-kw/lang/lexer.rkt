#lang racket/base

(provide make-colon-kw-lexer)

(require racket/bool
         racket/match
         )

(struct lexer-output [text type paren start end backup next-mode])

;; make-colon-kw-lexer/struct :
;; (Input-Port Natural Any -> Lexer-Output) -> (Input-Port Natural Any -> Lexer-Output)
(define (make-colon-kw-lexer/struct orig-lexer)
  ;; colon-kw-lexer : Input-Port Natural Any -> Lexer-Output
  (define (colon-kw-lexer in offset mode)
    (define c (peek-char in))
    (cond
      [(eof-object? c) (orig-lexer in offset mode)]
      [(char=? c #\:) (read-char in) (on-colon in offset mode colon-kw-lexer)]
      [else (orig-lexer in offset mode)]))
  colon-kw-lexer)

;; make-colon-kw-lexer : lexer/c -> lexer/c
(define (make-colon-kw-lexer orig-lexer)
  ;; my-orig-lexer : Input-Port Natural Any -> Lexer-Output
  (define my-orig-lexer
    (rkt-lexer->my-lexer orig-lexer))
  ;; my-lexer : Input-Port Natural Any -> Lexer-Output
  (define my-lexer
    (make-colon-kw-lexer/struct my-orig-lexer))
  (define colon-kw-lexer
    (case-lambda
     [(in)
      (lexer-output/1 (my-lexer in 0 #f))]
     [(in offset mode)
      (lexer-output/3 (my-lexer in offset mode))]))
  colon-kw-lexer)

;; on-colon : Input-Port Natural Any (-> Input-Port Natural Any Lexer-Output) -> Lexer-Output
(define (on-colon in offset mode recur)
  (match-define (lexer-output text type paren start end backup next-mode)
    (recur in offset mode))
  (cond
    [(symbol=? type 'symbol)
     (lexer-output (string-append ":" text)
                   'hash-colon-keyword
                   #f
                   (+ start -1)
                   end
                   (+ backup 1)
                   next-mode)]
    [else
     (lexer-output (string-append ":" (if (eof-object? text) "" text))
                   'error
                   paren
                   (+ start -1)
                   end
                   (+ backup 1)
                   next-mode)]))

(define (lexer-output/1 v)
  (match-define (lexer-output text type paren start end backup next-mode)
    v)
  (unless (false? next-mode) (error 'lexer-output "next-mode should be false, given: ~v" next-mode))
  (values text type paren start end))

(define (lexer-output/3 v)
  (match-define (lexer-output text type paren start end next-mode backup)
    v)
  (values type type paren start end next-mode backup))

;; rkt-lexer->my-lexer : lexer/c -> (Input-Port Natural Any -> Lexer-Output)
(define (rkt-lexer->my-lexer lexer)
  (cond
    [(procedure-arity-includes? lexer 1)
     ;; my-lexer : Input-Port Natural Any -> Lexer-Output
     (define (my-lexer in offset mode)
       ;; TODO: should offset be ignored in this case?
       (unless (false? mode) (error 'lexer "mode should be false, given: ~v" mode))
       (define-values [text type paren start end]
         (lexer in))
       (lexer-output text type paren start end 0 #f))
     my-lexer]
    [(procedure-arity-includes? lexer 3)
     ;; my-lexer : Input-Port Natural Any -> Lexer-Output
     (define (my-lexer in offset mode)
       (define-values [text type paren start end next-mode backup]
         (lexer in offset mode))
       (lexer-output text type paren start end 0 #f))
     my-lexer]
    [else
     (error 'lexer "arity should be 1 or 3, given: ~v" (procedure-arity lexer))]))

