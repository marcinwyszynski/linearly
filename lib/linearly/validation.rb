require 'singleton'

module Linearly
  class Validation
    def initialize(expectations)
      @expectations =
        expectations
        .map { |key, expectation| [key, Expectation.to_proc(expectation)] }
        .to_h
    end

    def call(state)
      Validator
        .new(expectations, state)
        .validate(error_class)
    end

    private

    attr_reader :expectations

    class Inputs < Validation
      private

      def error_class
        Errors::BrokenContract::Inputs
      end
    end # class Inputs

    class Outputs < Validation
      private

      def error_class
        Errors::BrokenContract::Outputs
      end
    end # class Outputs

    class Validator
      def initialize(expectations, state)
        @expectations = expectations
        @state = state
      end

      def validate(error_class)
        failures = invalid.merge(missing).freeze
        return @state if failures.empty?
        @state.fail(error_class.new(failures))
      end

      private

      def invalid
        @invalid ||= @expectations.map do |key, expectation|
          next nil if missing.key?(key)
          value = @state.fetch(key)
          next nil if expectation.call(value)
          [key, Failure::Unexpected.instance]
        end.compact.to_h
      end

      def missing
        @missing ||=
          @expectations
          .keys
          .reject { |key| @state.key?(key) }
          .map    { |key| [key, Failure::Missing.instance] }
          .to_h
      end
    end # class Validator
    private_constant :Validator

    class Failure
      include Singleton

      def inspect
        "[#{self.class.name.split('::').last.downcase}]"
      end

      class Missing < Failure
        def missing?
          true
        end
      end # class Missing

      class Unexpected < Failure
        def missing?
          false
        end
      end # class Unexpected
    end # class Failure

    module Expectation
      # This method reeks of :reek:TooManyStatements.
      def to_proc(expectation)
        klass = expectation.class
        return ->(value) { value.is_a?(expectation) } if klass == Class
        return ->(_) { true } if klass == TrueClass
        expectation
      end
      module_function :to_proc
    end # module Expectation
    private_constant :Expectation
  end # class Validation
end # module Linearly
