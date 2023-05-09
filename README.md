colon-kw
===
a racket lang-extension for writing `:kw` for `#:kw`

documentation: http://pkg-build.racket-lang.org/doc/colon-kw/index.html

You can use
```racket
#lang colon-kw racket
```
for `:kw` syntax, and
```racket
#lang kw-colon racket
```
for `kw:` syntax.

They are compose-able as well, so you can use
```racket
#lang colon-kw kw-colon racket
```
to let `:kw` and `kw:` both work in the same file.
