module Linearly
  # {Runner} is a wrapper around a single step with inputs and outputs, which
  # validates the inputs, runs the step, and validates the outputs.
  # @api private
  class Runner
    include Mixins::Reducer

    def initialize(step)
      @step = step
    end

    private

    attr_reader :step

    def steps
      [
        Validation::Preflight.new(step.inputs),
        step,
        Validation::Postflight.new(step.outputs),
      ]
    end
  end # class Runner
  private_constant :Runner
end # module Linearly
