require 'statefully'

module Linearly
  module Mixins
    # {Reducer} is a mixin to include in all classes which need to run more than
    # one step.
    # @api private
    module Reducer
      # Keep calling steps as long as the state is successful
      #
      # This method reeks of :reek:TooManyStatements and :reek:FeatureEnvy.
      #
      # @param state [Statefully::State]
      #
      # @return [Statefully::State]
      # @api private
      def call(state)
        steps.reduce(state) do |current, step|
          break current if current.failed? || current.finished?
          begin
            next_state = step.call(current)
          rescue StandardError => err
            break current.fail(err)
          end
          next next_state if next_state.is_a?(Statefully::State)
          current.fail(Errors::StateNotReturned.new(step))
        end
      end
    end
  end
  private_constant :Mixins
end
