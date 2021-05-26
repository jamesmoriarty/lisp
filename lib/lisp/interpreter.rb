module Lisp
  class << self
    def eval string
      execute parse tokenize string
    end

    def tokenize string
      string.gsub("(", " ( ").gsub(")", " ) ").split
    end

    def parse tokens, tree = []
      raise "unexpected: eof" if tokens.size.zero?

      case token = tokens.shift
      when "("
        while tokens[0] != ")" do
          tree.push parse tokens
        end
        tokens.shift
        tree
      when ")"
        raise "unexpected: )"
      else
        atom token
      end
    end

    def execute expression, scope = global
      return scope.fetch(expression) { |var| raise "#{var} is undefined" } if expression.is_a? Symbol
      return expression unless expression.is_a? Array

      case expression[0]
      when :define
        _, var, expression = expression
        scope[var] = execute expression, scope
      when :lambda
        _, params, expression = expression
        lambda { |*args| execute expression, scope.merge(Hash[params.zip(args)]) }
      when :if
        _, test, consequent, alternative = expression
        expression = if execute test, scope then consequent else alternative end
        execute expression, scope
      when :set!
        _, var, expression = expression
        if scope.has_key?(var) then scope[var] = execute expression, scope else raise "#{var} is undefined" end
      when :begin
        _, *expression = expression
        expression.map { |expression| execute expression, scope }.last
      else
        function, *args = expression.map { |expression| execute expression, scope }
        function.call *args
      end
    end

    private

    def atom token
      case token
      when /^[\p{N}\.]+$/
        token.to_f % 1 > 0 ? token.to_f : token.to_i
      else
        token.to_sym
      end
    end

    def global
      operators = [:==, :"!=", :"<", :"<=", :">", :">=", :+, :-, :*, :/]

      operators.inject({}) do |scope, operator|
        scope.merge operator => lambda { |*args| args.inject &operator }
      end
    end
  end
end
