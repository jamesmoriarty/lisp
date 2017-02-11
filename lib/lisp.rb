$LOAD_PATH.unshift File.dirname(__FILE__)

require 'lisp/version'
require 'lisp/repl'

module Lisp
  def self.eval(string)
    execute parse tokenize string
  end

  def self.tokenize(string)
    string.gsub('(', ' ( ').gsub(')', ' ) ').split
  end

  def self.parse(tokens, tree = [])
    raise 'unexpected: eof' if tokens.size.zero?

    case token = tokens.shift
    when '('
      tree.push parse tokens while tokens[0] != ')'
      tokens.shift
      tree
    when ')'
      raise 'unexpected: )'
    else
      atom token
    end
  end

  def self.atom(token)
    case token
    when /\d/
      token.to_f % 1 > 0 ? token.to_f : token.to_i
    else
      token.to_sym
    end
  end

  def self.execute(expression, scope = global)
    return scope.fetch(expression) { |var| raise "#{var} is undefined" } if expression.is_a? Symbol
    return expression                                                    unless expression.is_a? Array

    case expression[0]
    when :define
      _, var, expression = expression
      scope[var]         = execute expression, scope
    when :lambda
      _, params, expression = expression
      ->(*args) { execute expression, scope.merge(Hash[params.zip(args)]) }
    when :if
      _, test, consequent, alternative = expression
      expression                       = execute test, scope ? consequent : alternative
      execute expression, scope
    when :set!
      _, var, expression = expression
      scope.key?(var) ? (scope[var] = execute expression, scope) : (raise "#{var} is undefined")
    when :begin
      _, *expression = expression
      expression.map { |expression| execute expression, scope }.last
    else
      function, *args = expression.map { |expression| execute expression, scope }
      function.call *args
    end
  end

  def self.global
    @scope ||= begin
      operators = [:==, :"!=", :"<", :"<=", :">", :">=", :+, :-, :*, :/]
      operators.inject({}) do |scope, operator|
        scope.merge operator => ->(*args) { args.inject &operator }
      end
    end
  end
end
