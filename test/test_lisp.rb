#!/usr/bin/env ruby
require "bundler/setup"
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require "minitest/autorun"
require "pry"

require_relative "../lib/lisp"

class TestLisp < MiniTest::Unit::TestCase

  # parser

  def test_tokenize
    assert_equal ["(", "+", "1", "1", ")"], Lisp.tokenize("(+ 1 1)")
  end

  def test_parse
    assert_raises(RuntimeError) { Lisp.parse(Lisp.tokenize("(")) }
    assert_raises(RuntimeError) { Lisp.parse(Lisp.tokenize(")")) }
  end

  # representation

  def test_representation
    assert_equal [:*, 2, [:+, 1, 0]],                              Lisp.parse(Lisp.tokenize("(* 2 (+ 1 0) )"))
    assert_equal [:lambda, [:r], [:*, 3.141592653, [:*, :r, :r]]], Lisp.parse(Lisp.tokenize("(lambda (r) (* 3.141592653 (* r r)))"))
  end

  # execution

  def test_execution
    assert_equal 1, Lisp.execute(1)
    assert_equal 2, Lisp.execute([:*, 2, [:+, 1, 0]])
  end

  def test_eval
    assert_equal 2, Lisp.eval("(* 2 (+ 1 0) )")
  end

  def test_define
    Lisp.eval("(define pi 3.141592653)")
    assert_equal 6.283185306, Lisp.eval("(* pi 2)")
  end

  def test_if
    assert_equal 2, Lisp.eval("(if(== 1 2) 1 2)")
    assert_equal 1, Lisp.eval("(if(!= 1 2) 1 2)")
  end

  def test_set!
    assert_raises(RuntimeError) { Lisp.eval("(set! foo 0)") }
  end

  def test_begin
    assert_equal 4, Lisp.eval("(begin (define x 1) (set! x (+ x 1)) (* x 2))")
  end

  def test_lambda
    Lisp.eval("(define area (lambda (r) (* 3.141592653 (* r r))))")
    assert_equal 28.274333877, Lisp.eval("(area 3)")
    Lisp.eval("(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))")
    assert_equal 3628800, Lisp.eval("(fact 10)")
  end
end
