#!/usr/bin/env ruby
require "bundler/setup"

class Lisp
  class << self
    def repl
      puts "ctrl-c to exit"
      catch(:exit) do
        loop do
          print "> "
          puts begin
            eval gets
          rescue Exception => e
            e.message
          end
        end
      end
    end

    def eval(string)
      execute(parse(tokenize(string)))
    end

    def tokenize(string)
      string.gsub("("," ( ").gsub(")"," ) ").split
    end

    def parse(tokens, tree = [])
      raise "unexpected: eof" if tokens.size.zero?
      token = tokens.shift
      case token
      when "("
        while tokens[0] != ")" do
          tree.push parse(tokens)
        end
        tokens.shift
        tree
      when ")"
        raise "unexpected: )"
      else
        evaluator(token)
      end
    end

    def evaluator(token)
      case token
      when /\d/
        token.to_f
      else
        token.to_sym
      end
    end

    def execute(exp, scope = global)
      case exp
      when Array
        case exp[0]
        when :define
          _, var, exp = exp
          scope[var] = execute(exp, scope)
        when :lambda
          _, params, exp = exp
          proc { |*args| execute(exp, scope.merge(Hash[ params.zip(args) ])) }
        else
          exp.map! { |e| execute(e, scope) }
          func, *args = exp
          func.call(*args)
        end
      when Symbol
        scope[exp]
      else
        exp
      end
    end

    def global
      @scope ||= {
        :+ => Proc.new { |*args| args.inject(0, &:+) },
        :* => Proc.new { |*args| args.inject(1, &:*) }
      }
    end
  end
end

if __FILE__ == $0
   trap("SIGINT") { throw :exit }
   Lisp.repl
end
