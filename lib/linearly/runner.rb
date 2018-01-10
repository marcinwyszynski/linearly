module Linearly
  # {Runner} is a wrapper around a single step with inputs and outputs, which
  # validates the inputs, runs the step, and validates the outputs.
  # @api private
  class Runner
    include Mixins::StepCollection

    # Constructor for the {Runner} object
    # @param step [Step] anything that implements the +Step+ interface
    #        (+call+, +inputs+ and +outputs+ methods).
    #
    # @api private
    def initialize(step)
      @step = step
    end

    private

    # Return the wrapped {Step}
    #
    # @return [Step]
    # @api private
    attr_reader :step

    # Wrap the provided {Step} with input and output validation
    #
    # @return [Array<Step>]
    # @api private
    def steps
      [
        Validation::Inputs.new(step, step.inputs),
        step,
        Validation::Outputs.new(step, step.outputs),
      ]
    end
  end
  private_constant :Runner
end
