require 'spec_helper'

module Linearly
  describe Flow do
    let(:step1_proc) { ->(state) { state.succeed(new_key: :new_val) } }
    let(:step1) do
      TestStep.new(
        { key: String },
        { new_key: Symbol },
        step1_proc,
      )
    end
    let(:step2) do
      TestStep.new(
        { other: Numeric },
        {},
        ->(state) { state.succeed },
      )
    end
    let(:flow) { described_class.new(step1, step2) }

    describe '#inputs' do
      let(:inputs) { flow.inputs }

      it { expect(inputs.length).to eq 2 }
      it { expect(inputs.fetch(:key)).to eq String }
      it { expect(inputs.fetch(:other)).to eq Numeric }
    end # describe '#inputs'

    describe '#outputs' do
      let(:outputs) { flow.outputs }

      it { expect(outputs.length).to eq 1 }
      it { expect(outputs.fetch(:new_key)).to eq Symbol }
    end # describe '#outputs'

    describe '#call' do
      let(:state) { Statefully::State.create(**args) }
      let(:result) { flow.call(state) }

      context 'with correct input' do
        let(:args) { { key: 'val', other: 7 } }

        it { expect(result).to be_successful }
        it { expect(result.history.length).to eq 3 }

        context 'with a throwing step' do
          let(:step1_proc) { ->(_) { raise 'Boom!' } }

          it { expect(result).not_to be_successful }
          it { expect(result.error).to be_a RuntimeError }
        end # context 'with a throwing step'

        context 'with a step not returning State' do
          let(:step1_proc) { ->(_) { 'surprise!' } }

          it { expect(result).not_to be_successful }
          it { expect(result.error).to be_a Errors::StateNotReturned }
        end # context 'with a step not returning State'
      end # context 'with correct input'

      context 'with missing initial state' do
        let(:args) { { key: 'val' } }

        it { expect(result).to be_failed }
        it { expect(result.error).to be_a Errors::BrokenContract::Inputs }
        it { expect(result.history.length).to eq 2 }
      end # context 'with missing initial state'
    end # describe '#call'
  end # describe Flow
end # module Linearly
