require 'spec_helper'

module Linearly
  module Errors
    describe StateNotReturned do
      let(:output) { 'output' }
      let(:step) { 'step' }
      let(:error) { described_class.new(output: output, step: step) }

      it 'reports the right message' do
        expect(error.message)
          .to eq '"output", returned from step, is not a Statefully::State'
      end

      it { expect(error.output).to eq output }
      it { expect(error.step).to eq step }
    end
  end
end
