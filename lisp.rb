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

    def execute(exp, scope = global)
      if exp.is_a? Symbol
        scope[exp]
      elsif not exp.is_a? Array
        exp
      elsif exp[0] == :define
        _, var, exp = exp
        scope[var] = execute(exp, scope)
      elsif exp[0] == :lambda
        _, params, exp = exp
        proc { |*args| execute(exp, scope.merge(Hash[ params.zip(args) ])) }
      else
        exp.map! { |e| execute(e, scope) }
        func, *args = exp
        func.call(*args)
      end
    end

    def global
      @scope ||= {
        :+ => Proc.new { |*args| args.inject(0, &:+) },
        :* => Proc.new { |*args| args.inject(1, &:*) }
      }
    end

    def repl
      puts "ctrl-c to exit"
      catch(:exit) do
        loop do
          print "> "
          puts begin
            eval gets
          rescue Exception => e
            e.message or "unexpected: error"
          end
        end
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
   trap("SIGINT") { throw :exit }
   Lisp.repl
end
