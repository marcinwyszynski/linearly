require 'forwardable'

module Linearly
  class Flow
    extend Forwardable
    include Mixins::StepCollection

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

    # Convenience method to join +Step+s into one {Flow}
    #
    # @param other [Step]
    #
    # @return [Flow]
    # @api public
    # @example
    #   flow =
    #     Users::Find
    #     .>> Users::Update
    #     .>> Users::Save
    def >>(other)
      Flow.new(other, *@steps)
    end

    private

    # Steps to be ran by the {Flow}
    #
    # @return [Array<Step>]
    # @api private
    def steps
      [
        Validation::Inputs.new(inputs),
        *@steps.map(&Runner.method(:new)),
        Validation::Outputs.new(outputs),
      ]
    end

    # {Contract} is a companion for the {Flow}, providing it with logic for
    # properly determining required +inputs+ and expected +outputs+.
    class Contract
      extend Forwardable

      # Inputs required for the {Flow}
      #
      # @return [Hash<Symbol, TrueClass>]
      # @api private
      attr_reader :inputs

      # Outputs provided by the {Flow}
      #
      # @return [Hash<Symbol, TrueClass>]
      # @api private
      attr_reader :outputs

      # Constructor for the {Contract}
      #
      # @param steps [Array<Step>] array of things that implement the +Step+
      #        interface (+call+, +inputs+ and +outputs+ methods).
      #
      # @api private
      def initialize(steps)
        @steps = steps
        @inputs = {}
        @outputs = {}
        build
      end

      private

      # Figure out inputs required and outputs provided by the {Flow}
      #
      # @return [Array] irrelevant
      # @api private
      def build
        @steps.each(&method(:process))
        [@inputs, @outputs].map(&:freeze)
      end

      # Process a single step
      #
      # @param step [Step]
      #
      # @return [Hash] irrelevant
      # @api private
      def process(step)
        step.inputs.each do |key, val|
          @inputs[key] = val unless @inputs.key?(key) || @outputs.key?(key)
        end
        @outputs.merge!(step.outputs)
      end
    end
    private_constant :Contract
  end
end
