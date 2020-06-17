# frozen_string_literal: true

RSpec.describe ApplicationService, type: :service do
  describe '#call' do
    subject(:call) { described_class.new.call }

    it 'raises an error' do
      expect { call }.to raise_error(NotImplementedError)
    end
  end
end
