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
      #   Linearly::Errors::StateNotReturned.new('surprise').value
      #   => "surprise"
      attr_reader :value

      # Constructor for the {StateNotReturned} class
      #
      # @param value [Object]
      #
      # @api public
      # @example
      #   Linearly::Errors::StateNotReturned.new('surprise')
      def initialize(value)
        super("#{value.class.name} is not a Statefully::State")
        @value = value
      end
    end
  end
end
