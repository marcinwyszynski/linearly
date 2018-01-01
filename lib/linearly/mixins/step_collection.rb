require 'statefully'

module Linearly
  module Mixins
    # {StepCollection} is a mixin to include in all classes which need to run
    # more than one step.
    #
    # @api private
    module StepCollection
      # Keep calling steps as long as long as the state is successful
      #
      # This method reeks of :reek:TooManyStatements and :reek:FeatureEnvy.
      #
      # @param state [Statefully::State]
      #
      # @return [Statefully::State]
      # @api private
      def call(state)
        steps.reduce(state, &Reducer.method(:reduce))
      end

      # {Reducer} encapsulates the logic required to process a single Step in
      # a larger collection.
      #
      # @api private
      class Reducer
        # Public interface for the {Reducer}
        #
        # @param input [Statefully::State]
        # @param step [Step]
        #
        # @return [Statefully::State]
        # @api private
        def self.reduce(input, step)
          new(input: input, step: step).reduce
        end

        # Internal Reducer method to create {Step} output
        #
        # @return [Statefully::State]
        # @api private
        def reduce
          return input if input.failed? || input.finished?
          return input.fail(bad_output_error) unless state_returned?
          output
        end

        private

        # Return the original {Statefully::State}
        #
        # @return [Statefully::State]
        # @api private
        attr_reader :input

        # Return the {Step} to run
        #
        # @return [Step]
        # @api private
        attr_reader :step

        # Private constructor for the {Reducer}
        #
        # @param input [Statefully::State]
        # @param step [Step]
        #
        # @api private
        def initialize(input:, step:)
          @input = input
          @step = step
        end
        private_class_method :new

        # Construct an {Errors::StateNotReturned} error from internal state
        #
        # @return [Errors::StateNotReturned]
        # @api private
        def bad_output_error
          Errors::StateNotReturned.new(
            output: output,
            step: step.class.name,
          )
        end

        # Create output and memoize for reuse
        #
        # @return [Statefully::State]
        # @api private
        def output
          @output ||= begin
            step.call(input)
          rescue StandardError => error
            input.fail(error)
          end
        end

        # Check if output is an instance of {Statefully::State}
        #
        # @return [Boolean]
        # @api private
        def state_returned?
          output.is_a?(Statefully::State)
        end
      end
    end
  end
  private_constant :Mixins
end
