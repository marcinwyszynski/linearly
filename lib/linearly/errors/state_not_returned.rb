module Linearly
  module Errors
    # {StateNotReturned} is an error that is getting thrown when one of {Step}s
    # in the {Flow} does not return an instance of +Statefully::State+.
    # @api public
    class StateNotReturned < RuntimeError
      # Value that caused the error
      #
      # @return [Object]
      # @api public
      # @example
      #   Linearly::Errors::StateNotReturned
      #     .new(output: 'surprise', step: 'step')
      #     .output
      #   => "surprise"
      attr_reader :output

      # Name of the step that caused the error
      #
      # @return String
      # @api public
      # @example
      #   Linearly::Errors::StateNotReturned
      #     .new(output: 'surprise', step: 'step')
      #     .step
      #   => "step"
      attr_reader :step

      # Constructor for the {StateNotReturned} class
      #
      # @param output: [Object]
      # @param step: [String]
      #
      # @api public
      # @example
      #   Linearly::Errors::StateNotReturned
      #     .new(output: 'surprise', step: 'step')
      def initialize(output:, step:)
        str = output.inspect
        super("#{str}, returned from #{step}, is not a Statefully::State")
        @output = output
        @step = step
      end
    end
  end
end
