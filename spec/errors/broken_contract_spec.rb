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
      let(:error) { described_class.new('string', failures) }

      describe BrokenContract::Inputs do
        let(:message) do
          'failed input expectations on String: [missing, unexpected]'
        end

        it { expect(error.message).to eq message }
        it { expect(error.failures).to eq failures }
      end

      describe BrokenContract::Outputs do
        let(:message) do
          'failed output expectations on String: [missing, unexpected]'
        end

        it { expect(error.message).to eq message }
        it { expect(error.failures).to eq failures }
      end
    end
  end
end
