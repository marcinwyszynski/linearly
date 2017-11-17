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
    end
  end
end
