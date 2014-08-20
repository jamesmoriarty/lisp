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
    when /\d*\.\d*/
      token.to_f
    when /\d/
      token.to_i
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
    when :quote
      _, exp = exp
      exp
    when :set!
      _, var, exp = exp
      unless scope.has_key?(var)
        raise "#{var} must be defined before you can set! it"
      end
      scope[var] = execute(exp, scope)
    when :begin
      _ = exp.shift
      exp.map { |exp| execute(exp) }.last
    when :display
      _ = exp.shift
      exp.map { |exp| execute(exp) || exp }.join(' ').tap { |str| puts str }
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
