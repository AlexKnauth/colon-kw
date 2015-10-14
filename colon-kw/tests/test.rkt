#lang colon-kw racket/base

(require rackunit)

(define (a:b a :b c) (+ a c))
(check-equal? (a:b -1 :b -5) -6)
