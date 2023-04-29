#!/usr/bin/env ruby
require "lisp"

src = <<-CODE
(begin
  (define square (lambda (x) (* x x)))
  (square 9)
)
CODE

puts Lisp.eval(src)

