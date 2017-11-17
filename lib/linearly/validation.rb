require 'singleton'

module Linearly
  # {Validation} provides a way to check inputs and outputs against a set of
  # per-field expectations.
  # @abstract
  class Validation
    # Constructor for a {Validation}
    #
    # @param expectations [Hash<Symbol, Expectation>] a hash of per-field
    #        expectations. An expectation can be +true+ (just checking for field
    #        presence), a class name (checking for value type) or a +Proc+
    #        taking a value and returning a +Boolean+.
    #
    # @api private
    def initialize(expectations)
      @expectations =
        expectations
        .map { |key, expectation| [key, Expectation.to_proc(expectation)] }
        .to_h
    end

    # Call validation with a {State}
    #
    # @param state [Statefully::State]
    #
    # @return [Statefully::State]
    # @api private
    def call(state)
      Validator
        .new(expectations, state)
        .validate(error_class)
    end

    private

    # Wrapped expectations
    #
    # @return [Hash<Symbol, Expectation>]
    # @api private
    attr_reader :expectations

    # {Inputs} is a pre-flight {Validation} of {State} inputs
    class Inputs < Validation
      private

      # Return associated error class
      #
      # @return [Class]
      # @api private
      def error_class
        Errors::BrokenContract::Inputs
      end
    end

    # {Inputs} is a post-flight {Validation} of {State} outputs
    class Outputs < Validation
      private

      # Return associated error class
      #
      # @return [Class]
      # @api private
      def error_class
        Errors::BrokenContract::Outputs
      end
    end

    # {Validator} is a stateful helper applying expecations to a {State}
    class Validator
      # Constructor method for a {Validator}
      #
      # @param expectations [Hash<Symbol, Expectation>]
      # @param state [Statefully::State]
      #
      # @api private
      def initialize(expectations, state)
        @expectations = expectations
        @state = state
      end

      # Validate wrapped {State}, failing it with an error class if needed
      #
      # @param error_class [Class]
      #
      # @return [Statefully::State]
      # @api private
      def validate(error_class)
        failures = invalid.merge(missing).freeze
        return @state if failures.empty?
        @state.fail(error_class.new(failures))
      end

      private

      # Return the invalid fields
      #
      # @return [Hash<Field, Failure::Unexpected>]
      # @api private
      def invalid
        @invalid ||= @expectations.map do |key, expectation|
          next nil if missing.key?(key)
          value = @state.fetch(key)
          next nil if expectation.call(value)
          [key, Failure::Unexpected.instance]
        end.compact.to_h
      end

      # Return the missing fields
      #
      # @return [Hash<Field, Failure::Missing>]
      # @api private
      def missing
        @missing ||=
          @expectations
          .keys
          .reject { |key| @state.key?(key) }
          .map    { |key| [key, Failure::Missing.instance] }
          .to_h
      end
    end
    private_constant :Validator

    # {Failure} is a representation of a problem encountered when validating a
    # single {State} field.
    class Failure
      include Singleton

      # Human-readable representation of the {Failure}
      #
      # @return [String]
      # @api public
      # @example
      #   Linearly::Validation::Failure::Missing.instance.missing?
      #   => [missing]
      def inspect
        "[#{self.class.name.split('::').last.downcase}]"
      end

      # {Unexpected} is a type of {Failure} when a field does not exists
      class Missing < Failure
        # Check if the field is missing
        #
        # @return [FalseClass]
        # @api public
        # @example
        #   Linearly::Validation::Failure::Missing.instance.missing?
        #   => true
        def missing?
          true
        end
      end

      # {Unexpected} is a type of {Failure} when a field exists, but its value
      # does not match expectations.
      class Unexpected < Failure
        # Check if the field is missing
        #
        # @return [TrueClass]
        # @api public
        # @example
        #   Linearly::Validation::Failure::Unexpected.instance.missing?
        #   => true
        def missing?
          false
        end
      end
    end

    # {Expectation} is a helper module to turn various types of expectations
    # into {Proc}s.
    module Expectation
      # Turn one of the supported expecation types into a Proc
      #
      # This method reeks of :reek:TooManyStatements.
      #
      # @param expectation [Symbol|Class|Proc]
      #
      # @return [Proc]
      # @api private
      def to_proc(expectation)
        klass = expectation.class
        return ->(value) { value.is_a?(expectation) } if klass == Class
        return ->(_) { true } if klass == TrueClass
        expectation
      end
      module_function :to_proc
    end
  end
end
