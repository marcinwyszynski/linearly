require 'spec_helper'

module Linearly
  describe ImplicitStep do
    describe '.call' do
      let(:state) { Statefully::State.create(number: 7) }
      let(:result) { described_class.call(state) }

      it { expect { result.resolve }.to raise_error NameError }
    end
  end
end
