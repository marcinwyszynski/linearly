require 'forwardable'

# rubocop:disable Metrics/LineLength

module Linearly
  module Errors
    # BrokenContract is what happens when inputs or outputs for a {Step} do not
    # match expectations.
    # @abstract
    class BrokenContract < RuntimeError
      extend Forwardable

      # Input/output validation failures
      #
      # @return [Hash<Symbol, Validation::Failure>]
      # @api public
      # @examples
      #   err = Linearly::Errors::Inputs.new(
      #     key: Linearly::Validation::Failure::Missing.instance,
      #   )
      #   err.failures
      #   => {:key => [missing]}
      attr_reader :failures

      # @!method keys
      # @return [Array<Symbol>]
      # @see https://docs.ruby-lang.org/en/2.0.0/Hash.html#method-i-keys Hash#keys
      # @api public
      # @examples
      #   err = Linearly::Errors::Inputs.new(
      #     key: Linearly::Validation::Failure::Missing.instance,
      #   )
      #   err.keys
      #   => [:key]
      def_delegators :failures, :keys

      def initialize(failures)
        @failures = failures
        super("#{copy}: [#{keys.join(', ')}]")
      end

      class Inputs < BrokenContract
        private

        def copy
          'failed input expectations'
        end
      end # class Inputs

      class Outputs < BrokenContract
        private

        def copy
          'failed output expectations'
        end
      end # class Outputs
    end # class BrokenContract
  end # module Errors
end # module Linearly
