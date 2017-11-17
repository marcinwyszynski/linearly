require 'spec_helper'

module Linearly
  module Errors
    describe StateNotReturned do
      let(:value) { 'surprise!' }
      let(:error) { described_class.new(value) }

      it { expect(error.message).to eq 'String is not a Statefully::State' }
      it { expect(error.value).to eq value }
    end
  end
end
