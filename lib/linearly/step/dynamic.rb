module Linearly
  module Step
    module Dynamic
      include Mixins::FlowBuilder

      # Inputs for a step
      #
      # An invalid implementation is provided to ensure that a failure to
      # override this method is not quietly caught as a StandardError.
      #
      # @return [Hash<Symbol, Expectation>]
      # @api public
      # @example
      #   FindUser.new.inputs
      #   => { user_id: Integer }
      def inputs
        raise NotImplementedError
      end

      # Outputs for a step
      #
      # An invalid implementation is provided to ensure that a failure to
      # override this method is not quietly caught as a StandardError.
      #
      # @return [Hash<Symbol, Expectation>]
      # @api public
      # @example
      #   FindUser.new.outputs
      #   => { user: User }
      def outputs
        raise NotImplementedError
      end

      # User-defined logic for this +Step+
      #
      # An invalid implementation is provided to ensure that a failure to
      # override this method is not quietly caught as a StandardError.
      #
      # @param _state [Statefully::State]
      #
      # @return [Statefully::State]
      # @api public
      # @example
      #   FindUser.new.call(Statefully::State.create(user_id: 7))
      def call(_state)
        raise NotImplementedError
      end
    end # module Dynamic
  end # module Step
end # module Linearly
