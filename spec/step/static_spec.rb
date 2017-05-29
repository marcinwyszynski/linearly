require 'spec_helper'

module Linearly
  describe Step::Static do
    let(:args)  { {} }
    let(:state) { Statefully::State.create(**args) }

    it { expect { described_class.inputs }.to raise_error NotImplementedError }
    it { expect { described_class.outputs }.to raise_error NotImplementedError }

    describe '.call' do
      let(:result) { described_class.call(state) }

      it { expect { result }.to raise_error NotImplementedError }
    end # describe '.call'

    describe 'implementation' do
      subject { StaticStep }

      describe '.>>' do
        let(:flow) { subject.>>(subject) }

        it { expect(flow).to be_a Flow }
      end # describe '.>>'

      describe '.call' do
        let(:result) { subject.call(state) }

        context 'with missing input' do
          let(:args) { {} }

          it { expect(result).not_to be_successful }
          it { expect(result.error).to be_a NoMethodError }
        end # context 'with missing input'

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
      end # describe '.call'
    end # describe 'implementation'
  end # describe Step::Static
end # module Linearly
