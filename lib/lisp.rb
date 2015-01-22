require "bundler/setup"
require "lisp/version"
require "lisp/repl"

module Lisp
  def self.eval(string)
    execute(parse(tokenize(string)))
  end

  def self.tokenize(string)
    string.gsub("("," ( ").gsub(")"," ) ").split
  end

  def self.parse(tokens, tree = [])
    raise "unexpected: eof" if tokens.size.zero?

    case token = tokens.shift
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
    when /^\d+$/
      token.to_f
    else
      token.to_sym
    end
  end

  def self.execute(exp, scope = global)
    return scope[exp] if     exp.is_a? Symbol
    return exp        unless exp.is_a? Array

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
  end

  def self.global
    @scope ||= begin
      operators = [:==, :"!=", :"<", :"<=", :">", :">=", :+, :-, :*, :/]
      operators.inject({}) do |scope, operator|
        scope.merge(operator => lambda { |*args| args.inject(&operator) })
      end
    end
  end
end
