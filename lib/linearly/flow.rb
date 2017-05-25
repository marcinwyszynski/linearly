require 'forwardable'

module Linearly
  class Flow
    extend Forwardable
    include Mixins::Reducer

    # @!method call(state)
    #   Validate the input state and run steps as long as it's a +Success+
    #
    #   @param [Statefully::State] state
    #
    #   @return [Statefully::State]
    #   @api public
    #   @example
    #     flow = Linearly::Flow.new(
    #       Users::Find,
    #       Users::AddRole.new(:admin),
    #       Users::Save,
    #     )
    #     flow.call(Statefully::State.create(user_id: params[:id]))
    #
    # @!method inputs
    #   Inputs required for the {Flow}
    #
    #   @return [Hash<Symbol, TrueClass>]
    #   @api public
    #   @example
    #     Linearly::Flow.new(Users::Find).inputs
    #     => {user_id: true}
    #
    # @!method outputs
    #   Outputs provided by the {Flow}
    #
    #   @return [Hash<Symbol, TrueClass>]
    #   @api public
    #   @example
    #     Linearly::Flow.new(Users::Find).outputs
    #     => {user: true}
    def_delegators :@contract, :inputs, :outputs

    # Constructor for the {Flow}
    #
    # @param steps [Array<Step>] array of things that implement the +Step+
    #        interface (+call+, +inputs+ and +outputs+ methods).
    #
    # @api public
    # @example
    #   flow = Linearly::Flow.new(
    #     Users::Find,
    #     Users::AddRole.new(:admin),
    #     Users::Save,
    #   )
    def initialize(*steps)
      @steps = steps
      @contract = Contract.new(steps)
    end

    private

    # Steps to be ran by the {Flow}
    #
    # @return [Array<Step>]
    # @api private
    def steps
      [
        Validation::Inputs.new(inputs),
        *steps.map(&Runner.method(:new)),
        Validation::Outputs.new(outputs),
      ]
    end

    # {Contract} is a companion for the {Flow}, providing it with logic for
    # properly determining required +inputs+ and expected +outputs+.
    class Contract
      # Constructor for the {Contract}
      #
      # @param steps [Array<Step>] array of things that implement the +Step+
      #        interface (+call+, +inputs+ and +outputs+ methods).
      #
      # @api private
      def initialize(steps)
        @steps = steps
        @inputs = Set.new
        @outputs = Set.new
        build
      end

      # Inputs required for the {Flow}
      #
      # @return [Hash<Symbol, TrueClass>]
      # @api private
      def inputs
        @inputs.map { |key| [key, true] }.to_h
      end

      # Outputs provided for the {Flow}
      #
      # @return [Hash<Symbol, TrueClass>]
      # @api private
      def outputs
        @outputs.map { |key| [key, true] }.to_h
      end

      private

      # Figure out inputs required and outputs provided by the {Flow}
      #
      # @return [Array] irrelevant
      # @api private
      def build
        @steps.each do |step|
          @inputs += (Set.new(step.inputs.keys) - @outputs)
          @outputs += step.outputs.keys
        end
        [@inputs, @outputs].map(&:freeze)
      end
    end # class Contract
    private_constant :Contract
  end # class Flow
end # module Linearly
