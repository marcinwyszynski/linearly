module Linearly
  class StaticStep < Step::Static
    def self.inputs
      { number: Integer }
    end

    def self.outputs
      { string: String }
    end

    def call
      succeed(string: (number + 1).to_s + correlation_id)
    end
  end
end
