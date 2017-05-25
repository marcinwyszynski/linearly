require 'spec_helper'

module Linearly
  module Errors
    describe BrokenContract do
      let(:failures) do
        {
          missing: Validation::Failure::Missing.instance,
          unexpected: Validation::Failure::Unexpected.instance,
        }
      end
      let(:error) { described_class.new(failures) }

      describe BrokenContract::Inputs do
        let(:message) { 'failed input expectations: [missing, unexpected]' }

        it { expect(error.message).to eq message }
        it { expect(error.failures).to eq failures }
      end # describe BrokenContract::Inputs

      describe BrokenContract::Outputs do
        let(:message) { 'failed output expectations: [missing, unexpected]' }

        it { expect(error.message).to eq message }
        it { expect(error.failures).to eq failures }
      end # describe BrokenContract::Outputs
    end # describe BrokenContract
  end # module Errors
end # module Linearly
