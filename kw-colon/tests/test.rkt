#lang kw-colon racket/base

(require rackunit)

(define (a:b a :b b: c) (+ a :b c))
(check-equal? (a:b -1 -2 b: -5) -8)
