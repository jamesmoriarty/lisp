#!/usr/bin/env ruby

require "bundler/setup"
require "lisp/version"

module Lisp
  def self.repl
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

  def self.eval(string)
    execute(parse(tokenize(string)))
  end

  def self.tokenize(string)
    string.gsub("("," ( ").gsub(")"," ) ").split
  end

  def self.parse(tokens, tree = [])
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

  def self.evaluator(token)
    case token
    when /\d/
      token.to_f
    else
      token.to_sym
    end
  end

  def self.execute(exp, scope = global)
    case exp
    when Array
      case exp[0]
      when :define
        _, var, exp = exp
        scope[var] = execute(exp, scope)
      when :lambda
        _, params, exp = exp
        lambda { |*args| execute(exp, scope.merge(Hash[params.zip(args)])) }
      when :if
        _, test, conseq, alt = exp
        exp = execute(test, scope) ? conseq : alt
        execute(exp, scope)
      else
        func, *args = exp.map { |exp| execute(exp, scope) }
        func.call(*args)
      end
    when Symbol
      scope[exp]
    else
      exp
    end
  end

  def self.global
    @scope ||= begin
      methods = [:==, :"!=", :"<", :"<=", :">", :">=", :+, :-, :*, :/]
      methods.inject({}) do |scope, method|
        scope.merge(method => lambda { |*args| args.inject(&method) })
      end
    end
  end
end

if __FILE__ == $0
   trap("SIGINT") { throw :exit }
   Lisp.repl
end
