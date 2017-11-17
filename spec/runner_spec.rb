require 'spec_helper'

module Linearly
  describe Runner do
    let(:state)    { Statefully::State.create(key: 'val') }
    let(:behavior) { ->(state) { state.succeed(new_key: 'new_val') } }
    let(:inputs)   { { key: true } }
    let(:outputs)  { { new_key: true } }
    let(:step)     { TestStep.new(inputs, outputs, behavior) }
    let(:result)   { described_class.new(step).call(state) }

    context 'when all goes well' do
      it { expect(result).to be_successful }
      it { expect(result).not_to be_finished }
      it { expect(result.key).to eq 'val' }
    end

    shared_examples 'returns_error' do |error_class|
      it { expect(result).not_to be_successful }
      it { expect(result.error).to be_a error_class }
    end

    context 'when input validation fails' do
      let(:inputs) { { other: true } }

      it_behaves_like 'returns_error', Errors::BrokenContract::Inputs
    end

    context 'when step fails' do
      let(:behavior) { ->(state) { state.fail(RuntimeError.new('Boom!')) } }

      it_behaves_like 'returns_error', RuntimeError
    end

    context 'when step finishes' do
      let(:behavior) { ->(state) { state.finish } }

      it { expect(result).to be_finished }
    end

    context 'when output validation fails' do
      let(:outputs) { { other: true } }

      it_behaves_like 'returns_error', Errors::BrokenContract::Outputs
    end
  end
end
