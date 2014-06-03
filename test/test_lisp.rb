#!/usr/bin/env ruby
require "bundler/setup"
require "pry"
require "simplecov"
require "minitest/autorun"

SimpleCov.start

require_relative "../lisp"

class TestLisp < MiniTest::Unit::TestCase

  # parser

  def test_tokenize
    assert_equal ["(", "+", "1", "1", ")"], Lisp.tokenize("(+ 1 1)")
  end

  def test_parse
    assert_equal [:*, 2, [:+, 1, 0]],                              Lisp.parse(Lisp.tokenize("(* 2 (+ 1 0) )"))
    assert_equal [:lambda, [:r], [:*, 3.141592653, [:*, :r, :r]]], Lisp.parse(Lisp.tokenize("(define area(lambda (r) (* 3.141592653 (* r r))))"))
  end

  # representation

  def test_representation
    skip
  end

  # execution

  def test_execution
    assert_equal 1, Lisp.execute([1])
    assert_equal 2, Lisp.execute([:*, 2, [:+, 1, 0]])
    assert_equal 2, Lisp.eval("(* 2 (+ 1 0) )")
  end

  def test_define
    Lisp.eval("(define pi 3.141592653)")
    
    assert_equal 6.283185306, Lisp.eval("(* pi 2)")
  end

  def test_lambda
    Lisp.eval("(define area (lambda (r) (* 3.141592653 (* r r)))")

    assert_equal 12.566370612, Lisp.eval("(area 2)")
  end
end
