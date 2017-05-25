require 'spec_helper'

module Linearly
  describe Step::Static do
    let(:flow)   { Flow.new(StaticStep) }
    let(:state)  { Statefully::State.create(**args) }
    let(:result) { flow.call(state) }

    context 'with correct input' do
      let(:args) { { number: 7 } }

      it { expect(result).to be_successful }
      it { expect(result.string).to eq '8' }
    end # context 'with correct input'

    context 'with incorrect input' do
      let(:args) { { number: '7' } }

      it { expect(result).not_to be_successful }
      it { expect(result.error).to be_a Errors::BrokenContract::Inputs }
    end # context 'with incorrect input'
  end # describe Step::Static
end # module Linearly
