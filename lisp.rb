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
      token = tokens.shift

      case token
      when "("
        while tokens.first != ")" do
          representation.push parse(tokens)
        end
        tokens.shift
        representation
      else
        atom(token)
      end
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

      # execution
      # [:*, 2, [:+, 1, 0]]
      # [:*, 2, 1]
      atom = representation.shift
      case atom
      when :define
        var, *representation = representation
        representation       = representation.size > 1 ? representation : representation[0]

        env[var]             = execute representation
      when :lambda
        var, *parameters, representation = representation

        env[var] = Proc.new { |*arguments| execute representation, Hash[parameters.zip(arguments)] }
      when Proc
        function  = atom
        arguments = representation

        if function.respond_to?(:call)
          function.call(*arguments)
        else
          function
        end
      else
        atom
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
