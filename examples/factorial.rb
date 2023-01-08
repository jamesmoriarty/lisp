#!/usr/bin/env ruby
require "lisp"

src = <<-eos
  (begin
    (define fact
      (lambda (n)
        (if (<= n 1)
          1
          (* n (fact (- n 1))))))
    (fact 10))
eos

puts Lisp.eval(src) # => 362880
