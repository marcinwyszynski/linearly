require 'spec_helper'

module Linearly
  describe Step::Static do
    let(:args)  { {} }
    let(:state) { Statefully::State.create(**args) }

    it { expect { described_class.inputs }.to raise_error NotImplementedError }
    it { expect { described_class.outputs }.to raise_error NotImplementedError }

    context 'with result' do
      let(:result) { described_class.call(state) }

      it { expect { result }.to raise_error NotImplementedError }
    end # context 'with result'

    describe 'implementation' do
      let(:result) { StaticStep.call(state) }

      context 'with correct input' do
        let(:args) { { number: 7 } }

        it { expect(result).to be_successful }
        it { expect(result.string).to eq '8' }
      end # context 'with correct input'

      context 'with incorrect input' do
        let(:args) { { number: '7' } }

        it { expect(result).not_to be_successful }
        it { expect(result.error).to be_a TypeError }
      end # context 'with incorrect input'

      context 'with missing input' do
        let(:args) { {} }

        it { expect(result).not_to be_successful }
        it { expect(result.error).to be_a NoMethodError }
      end # context 'with incorrect input'
    end # describe 'implementation'
  end # describe Step::Static
end # module Linearly
