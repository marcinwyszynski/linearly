require 'spec_helper'

module Linearly
  module Step
    describe Dynamic do
      let(:step) { DynamicStep.new }

      describe '#inputs' do
        it { expect { step.inputs }.to raise_error NotImplementedError }
      end # describe '#inputs'

      describe '#outputs' do
        it { expect { step.outputs }.to raise_error NotImplementedError }
      end # describe '#outputs'

      describe '#call' do
        let(:state) { Statefully::State.create }

        it { expect { step.call(state) }.to raise_error NotImplementedError }
      end # describe '#call'

      describe '#>>' do
        let(:step) { DynamicStep::Valid.new }

        it { expect(step.>>(step)).to be_a Flow }
      end # describe '#>>'
    end # describe Dynamic
  end # module Step
end # module Linearly
