#!/usr/bin/env ruby
require "bundler/setup"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support', '*.rb'))].each { |file| require file }

require "lisp"
require "minitest/autorun"

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
    assert_equal 6.283185306, Lisp.eval(<<-eos)
      (begin
        (define pi 3.141592653)
        (* pi 2))
    eos
  end

  def test_if
    assert_equal 2, Lisp.eval("(if(== 1 2) 1 2)")
    assert_equal 1, Lisp.eval("(if(!= 1 2) 1 2)")
  end

  def test_set!
    assert_raises(RuntimeError) { Lisp.eval("(set! foo 0)") }
  end

  def test_begin
    assert_equal 4, Lisp.eval(<<-eos)
      (begin
        (define x 1)
        (set! x (+ x 1)) (* x 2))
    eos
  end

  def test_lambda
    assert_equal 28.274333877, Lisp.eval(<<-eos)
      (begin
        (define area
          (lambda (r)
            (* 3.141592653 (* r r))))
        (area 3))
    eos
  end

  def test_lambda_call_self
    assert_equal 3628800, Lisp.eval(<<-eos)
      (begin
        (define fact
          (lambda (n)
            (if (<= n 1)
              1
              (* n (fact (- n 1))))))
        (fact 10))
    eos
  end

  def test_lambda_call_arg
    assert_equal 40, Lisp.eval(<<-eos)
      (begin
        (define twice (lambda (x) (* 2 x)))
        (define repeat (lambda (f) (lambda (x) (f (f x)))))
        ((repeat twice) 10)))
    eos
  end

  def test_program
    assert_equal 2, Lisp.eval(<<-eos)
      (begin
        (define incf
          (lambda (x)
            (set! x (+ x 1))))
        (define one 1)
        (incf one))
    eos
  end

  def test_repl
    pid     = Process.pid
    subject = Lisp::REPL.new
    thread  = Thread.new do
      sleep 1
      Process.kill("INT", pid)
      thread.join
    end
    
    assert_output("ctrl-c to exit\n") do
      subject.run
    end
  end
end
