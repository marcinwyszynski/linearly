module Linearly
  module Mixins
    module FlowBuilder
      # @!method self.>>(other)
      # Convenience method to create a {Flow} from linked Steps
      #
      # @param other [Step] next step in the {Flow}
      #
      # @return [Flow]
      # @api public
      # @example
      #   flow =
      #     Users::Find
      #     .>> Users::Update
      #     .>> Users::Save
      def >>(other)
        Flow.new(self, other)
      end
    end
  end
  private_constant :Mixins
end
