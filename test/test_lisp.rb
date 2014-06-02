#!/usr/bin/env ruby
require 'simplecov'
SimpleCov.start

require "bundler/setup"
require "minitest/autorun"
require_relative "../lisp"

class TestLisp < MiniTest::Unit::TestCase

  # parser

  def test_tokenize
    assert_equal ["(", "+", "1", "1", ")"], Lisp.tokenize("(+ 1 1)")
  end

  def test_parse
    assert_equal [:*, 2, [:+, 1, 0]], Lisp.parse(Lisp.tokenize("(* 2 (+ 1 0) )"))
  end

  # representation

  def test_representation
    skip
  end

  # execution

  def test_execution
    assert_equal 2, Lisp.eval("(* 2 (+ 1 0) )")
  end
end
