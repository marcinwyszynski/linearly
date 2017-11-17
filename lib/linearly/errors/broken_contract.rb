require 'forwardable'

# rubocop:disable Metrics/LineLength

module Linearly
  module Errors
    # {BrokenContract} is what happens when inputs or outputs for a {Step} do
    # not match expectations.
    # @abstract
    class BrokenContract < RuntimeError
      extend Forwardable

      # Input/output validation failures
      #
      # @return [Hash<Symbol, Validation::Failure>]
      # @api public
      # @example
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
      # @example
      #   err = Linearly::Errors::BrokenContract::Inputs.new(
      #     key: Linearly::Validation::Failure::Missing.instance,
      #   )
      #   err.keys
      #   => [:key]
      def_delegators :failures, :keys

      # Constructor for a {BrokenContract} error
      #
      # @param failures [Hash<Symbol, Validation::Failure>]
      #
      # @api public
      # @example
      #   Linearly::Errors::BrokenContract::Inputs.new(
      #     key: Linearly::Validation::Failure::Missing.instance,
      #   )
      #   => #<Linearly::Errors::BrokenContract::Inputs:
      #        failed input expectations: [key]>
      def initialize(failures)
        @failures = failures
        super("#{copy}: [#{keys.join(', ')}]")
      end

      # {Inputs} means a {BrokenContract} on inputs.
      class Inputs < BrokenContract
        private

        # Copy for the error message
        #
        # @return [String]
        # @api private
        def copy
          'failed input expectations'
        end
      end

      # {Outputs} means a {BrokenContract} on outputs.
      class Outputs < BrokenContract
        private

        # Copy for the error message
        #
        # @return [String]
        # @api private
        def copy
          'failed output expectations'
        end
      end
    end
  end
end
