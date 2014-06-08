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
          lambda { |*args| execute(exp, Scope.new(params, args, scope)) }
        when :if
          _, test, conseq, alt = exp
          exp = execute(test, scope) ? conseq : alt
          execute(exp, scope)
        else
          exps = exp.map { |exp| execute(exp, scope) }
          func, *args = exps
          func.call(*args)
        end
      when Symbol
        scope[exp]
      else
        exp
      end
    end

    def global
      @scope ||= begin
        methods = [:==, :"!=", :"<", :"<=", :">", :">=", :+, :-, :*, :/]
        methods.inject(Scope.new) do |methods, method|
          methods.merge(method => lambda { |*args| args.inject(&method) })
        end
      end
    end
  end

  class Scope < Hash
    attr_accessor :outer

    def initialize(params = [], args = [], outer = nil)
      update(Hash[params.zip(args)])
      self.outer = outer
    end

    def [](name)
      super or outer[name]
    end
  end
end

if __FILE__ == $0
   trap("SIGINT") { throw :exit }
   Lisp.repl
end
