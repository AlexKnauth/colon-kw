#lang scribble/manual

@title{colon-kw and kw-colon}

source code: @url{https://github.com/AlexKnauth/colon-kw}

@section{colon-kw}

@defmodule[colon-kw #:lang]{
A lang-extension that adds @racket[:kw] syntax as an alternative to @racket[#:kw]
to any racket language that looks at the current readtable.

For example,
@codeblock{
#lang colon-kw racket
}
Is a language like racket, except that @racket[:kw] reads equivalent to
@racket[#:kw].
}

@section{kw-colon}

@defmodule[kw-colon #:lang]{
A lang-extension that adds @racket[kw:] syntax as an alternative to
@racket[#:kw].

For example,
@codeblock{
#lang kw-colon racket
}
Is a language like racket, except that @racket[kw:] can be used in place of
@racket[#:kw].
}

These two lang-extensions are compose-able as well, so you can use
@codeblock{
#lang colon-kw kw-colon racket
}
to let @racket[:kw] and @racket[kw:] both work in the same file.

