require 'spec_helper'

module Linearly
  describe Validation do
    let(:validation) { described_class.new(expectations).call(state) }
    let(:state)      { Statefully::State.create(key: 'val') }

    shared_examples 'validation_fails' do |error_class|
      it { expect(validation).to be_failed }
      it { expect(validation.error).to be_a error_class }
    end # shared_examples 'validation_fails'

    shared_examples 'fails_when_missing_field' do |error_class|
      let(:field) { :other }

      it_behaves_like 'validation_fails', error_class

      it { expect(validation.error).to be_a error_class }

      context 'with failures' do
        let(:failures) { validation.error.failures }

        it { expect(validation.error.failures).to have_key(field) }
        it { expect(validation.error.failures.fetch(field)).to be_missing }
      end # context 'with failures'
    end # shared_examples 'fails_when_missing_field'

    shared_examples 'fails_with_unexpected_value' do |error_class|
      it_behaves_like 'validation_fails', error_class

      it { expect(validation.error).to be_a error_class }

      context 'with failures' do
        let(:failures) { validation.error.failures }

        it { expect(validation.error.failures).to have_key(field) }
        it { expect(validation.error.failures.fetch(field)).not_to be_missing }
      end # context 'with failures'
    end # shared_examples 'fails_with_unexpected_value'

    shared_examples 'succeeds_and_returns_state' do
      it { expect(validation).to be_successful }
      it { expect(validation).to eq state }
    end # shared_examples 'succeeds_and_returns_state'

    shared_examples 'supports_presence_expectation' do |error_class|
      let(:field)        { :key }
      let(:expectations) { { field => true } }

      it_behaves_like 'fails_when_missing_field', error_class
      it_behaves_like 'succeeds_and_returns_state'
    end # shared_examples 'supports_presence_expectation'

    shared_examples 'supports_class_expectation' do |error_class|
      let(:field)        { :key }
      let(:klass)        { String }
      let(:expectations) { { field => klass } }

      it_behaves_like 'fails_when_missing_field', error_class

      context 'when expectation is met (default)' do
        it_behaves_like 'succeeds_and_returns_state'
      end # context 'when expectation is met (default)'

      context 'when expectation is not met' do
        let(:klass) { Numeric }

        it_behaves_like 'fails_with_unexpected_value', error_class
      end # context 'when expectation is not met'
    end # shared_examples 'supports_class_expectation'

    shared_examples 'supports_proc_expectation' do |error_class|
      let(:field)        { :key }
      let(:klass)        { String }
      let(:expectation)  { ->(val) { val.length == 3 } }
      let(:expectations) { { field => expectation } }

      it_behaves_like 'fails_when_missing_field', error_class

      context 'when expectation is met (default)' do
        it_behaves_like 'succeeds_and_returns_state'
      end # context 'when expectation is met (default)'

      context 'when expectation is not met' do
        let(:expectation) { ->(val) { val.length == 4 } }

        it_behaves_like 'fails_with_unexpected_value', error_class
      end # context 'when expectation is not met'
    end # shared_examples 'supports_proc_expectation'

    describe Validation::Inputs do
      it_behaves_like 'supports_presence_expectation', Errors::BrokenContract::Inputs
      it_behaves_like 'supports_class_expectation', Errors::BrokenContract::Inputs
      it_behaves_like 'supports_proc_expectation', Errors::BrokenContract::Inputs
    end # describe Validation::Inputs

    describe Validation::Outputs do
      it_behaves_like 'supports_presence_expectation', Errors::BrokenContract::Outputs
      it_behaves_like 'supports_class_expectation', Errors::BrokenContract::Outputs
      it_behaves_like 'supports_proc_expectation', Errors::BrokenContract::Outputs
    end # describe Validation::Outputs
  end # describe Validation
end # module Linearly
