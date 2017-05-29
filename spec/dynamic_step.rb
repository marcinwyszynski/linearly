module Linearly
  class DynamicStep
    include Step::Dynamic

    class Valid < DynamicStep
      def inputs
        {}
      end

      def outputs
        {}
      end
    end # class Valid
  end # class DynamicStep
end # module Linearly
