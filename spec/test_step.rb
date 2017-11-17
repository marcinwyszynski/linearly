require 'forwardable'

module Linearly
  class TestStep
    extend Forwardable

    attr_reader :inputs, :outputs
    def_delegators :@behavior, :call

    def initialize(inputs, outputs, behavior)
      @inputs = inputs
      @outputs = outputs
      @behavior = behavior
    end
  end
end
