module Linearly
  class ImplicitStep < Step::Static
    def self.inputs
      {}
    end

    def call
      succeed(string: (number + 1).to_s)
    end
  end
end
