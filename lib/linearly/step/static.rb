module Linearly
  module Step
    # {Static} is a type of +Step+ whose operation solely depends on the content
    # of the +State+ passed to its {.call} method. It's the best and most
    # deterministic type of a +Step+, hence we provided a helper. Inheriting
    # from {Static} will still require you to implement three methods: class
    # +inputs+ and +outputs+ methods, and an instance +call+ method. What you
    # get though is that your +call+ method does not need to take any parameters
    # and will have access to the private +state+ instance variable. What's
    # more, any unknown messages will be forwarded to +state+, so that your code
    # can be shorter and more expressive. Also, you don't have to explicitly
    # rescue exceptions - the static {.call} method will catch those and fail
    # the +state+ accordingly.
    class Static
      extend Mixins::FlowBuilder

      # Main entry point to {Step::Static}
      #
      # @param state [Statefully::State]
      #
      # @return [Statefully::State]
      # @api public
      # @example
      #   class FindUser < Linearly::Step::Static
      #     def self.inputs
      #       { user_id: Integer }
      #     end
      #
      #     def self.outputs
      #       { user: User }
      #     end
      #
      #     def call
      #       succeed(user: User.find(user_id))
      #     end
      #   end # class FindUser
      #   FindUser.call(Statefully::State.create(user_id: params[:id]))
      def self.call(state)
        new(state).call
      rescue StandardError => err
        state.fail(err)
      end

      # User-defined logic for this +Step+
      #
      # @return [Statefully::State]
      # @api private
      def call
        raise NotImplementedError
      end

      # Inputs for a step
      #
      # @return [Hash<Symbol, Expectation>]
      # @api public
      # @example
      #   FindUser.inputs
      #   => { user_id: Integer }
      def self.inputs
        raise NotImplementedError
      end

      # Outputs for a step
      #
      # @return [Hash<Symbol, Expectation>]
      # @api public
      # @example
      #   FindUser.outputs
      #   => { user: User }
      def self.outputs
        raise NotImplementedError
      end

      private

      # {State} received through the constructor
      #
      # @return [Statefully::State]
      # @api private
      attr_reader :state

      # Constructor for the {Step::Static}
      #
      # @param state [Statefully::State]
      # @api private
      def initialize(state)
        @state = state
      end
      private_class_method :new

      # Dynamically pass unknown messages to the wrapped +State+
      #
      # @param name [Symbol|String]
      # @param args [Array<Object>]
      # @param block [Proc]
      #
      # @return [Object]
      # @raise [NoMethodError]
      # @api private
      def method_missing(name, *args, &block)
        state.send(name, *args, &block)
      rescue NoMethodError
        super
      end

      # Companion to `method_missing`
      #
      # This method reeks of :reek:BooleanParameter.
      #
      # @param name [Symbol|String]
      # @param include_private [Boolean]
      #
      # @return [Boolean]
      # @api private
      def respond_to_missing?(name, include_private = false)
        state.send(:respond_to_missing?, name, include_private)
      end
    end # class Static
  end # module Step
end # module Linearly
