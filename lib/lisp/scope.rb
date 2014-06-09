module Lisp
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
