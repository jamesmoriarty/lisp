#!/usr/bin/env ruby
require "bundler/setup"

class Lisp
  class << self
    def repl
      while true do
        print "> "
        puts eval(gets)
      end
    end

    def eval(string)
      execute parse(tokenize(string))
    end

    def tokenize(string)
      string.gsub('(',' ( ').gsub(')',' ) ').split
    end

    def parse(tokens)
      _parse(tokens)[0]
    end

    def execute(representation, env = env)
      return representation unless representation.is_a?(Array)

      # depth first traversal of representation
      # [:*, 2, [:+, 1, 0]]
      # [:+, 1, 0]
      representation = representation.map do |atom|
        case atom
        when Array
          execute atom
        else
          env[atom] or atom
        end
      end

      # depth first execution
      # [:*, 2, [:+, 1, 0]]
      # [:*, 2, 1]
      atom = representation.shift
      case atom
      when :define
        var, *arguments = representation
        arguments       = arguments[0]
        env[var]        = arguments
      when Proc
        function  = atom
        arguments = representation
        function.respond_to?(:call) ? function.call(*arguments) : function
      else
        atom
      end
    end

    private

    def env
      @env ||= {
        :+ => Proc.new { |*args| args.inject(0, &:+) },
        :* => Proc.new { |*args| args.inject(1, &:*) }
      }
    end

    def atom(token)
      case token
      when /\d/
        token.to_f
      else
        token.to_sym
      end
    end

    def _parse(tokens, representation = [])
      token = tokens.shift

      case token
      when "("
        representation.push _parse(tokens)
      when ")"
        representation
      else
        _parse tokens, representation.push(atom(token))
      end
    end
  end
end

if __FILE__ == $0
   Lisp.repl
end
