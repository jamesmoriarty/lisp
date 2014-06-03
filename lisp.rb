#!/usr/bin/env ruby
require "bundler/setup"

class Lisp
  class << self
    def eval(string)
      execute parse(tokenize(string))
    end

    def tokenize(string)
      string.gsub('(',' ( ').gsub(')',' ) ').split
    end

    def parse(tokens, representation = [])
      raise "unexpected: eof" if tokens.size.zero?

      token = tokens.shift

      case token
      when "("
        while tokens[0] != ")" do
          representation.push parse(tokens)
        end
        tokens.shift
        representation
      when ")"
        raise "unexpected: )"
      else
        atom(token)
      end
    end

    def execute(expression, env = env)
      if expression.is_a? Symbol
        env[expression]
      elsif not expression.is_a? Array
        expression
      elsif expression[0] == :define
        _, var, *expression = expression
        env[var]            = execute(expression)
      elsif expression[0] == :lambda
        _, parameters, expression = expression
        Proc.new { |*arguments| execute expression, env.merge(Hash[ parameters.zip(arguments) ]) }
      else
        expression.map! { |expression| execute expression }

        function, *arguments = expression
        function.call(*arguments)
      end
    end

    def env
      @env ||= {
        :+ => Proc.new { |*args| args.inject(0, &:+) },
        :* => Proc.new { |*args| args.inject(1, &:*) }
      }
    end

    def repl
      while true do
        print "> "
        puts eval(gets)
      end
    end

    def atom(token)
      case token
      when /\d/
        token.to_f
      else
        token.to_sym
      end
    end
  end
end

if __FILE__ == $0
   Lisp.repl
end
