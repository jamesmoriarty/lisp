#!/usr/bin/env ruby

class Lisp
  class << self
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
          atom
        end
      end

      # depth first execution
      # [:*, 2, [:+, 1, 0]]
      # [:*, 2, 1]
      atom = representation.shift
      case atom
      when Symbol
        function  = env[atom]
        arguments = representation
        function.call(*arguments)
      end
    end

    private

    def env
      {
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
