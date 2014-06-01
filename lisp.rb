#!/usr/bin/env ruby

class Lisp
  class << self
    def tokenize(string)
      string.gsub('(',' ( ').gsub(')',' ) ').split
    end

    def parse(tokens)
      _parse(tokens)[0]
    end

    private

    def _parse(tokens, representation = [])
      token = tokens.shift

      case token
      when "("
        representation.push _parse(tokens)
      when ")"
        representation
      when nil
        representation
      else
        _parse tokens, representation.push(token)
      end
    end
  end
end

require "minitest/autorun"

class TestLisp < Minitest::Test

  # parser

  def test_tokenize
    assert_equal ["(", "+", "1", "1", ")"], Lisp.tokenize("(+ 1 1)")
  end

  def test_parse
    assert_equal ["*", "2", ["+", "1", "0"]], Lisp.parse(Lisp.tokenize("(* 2 (+ 1 0) )"))
  end

  # representation

  def test_representation
    skip
  end

  # execution

  def test_execution
    skip
  end
end
