# frozen_string_literal: true

RSpec.describe ApplicationQuery, type: :query do
  let(:query) { described_class.new(Ticket.all) }

  describe '#call' do
    subject(:call) { query.call }

    it 'raises an error' do
      expect { call }.to raise_error(NotImplementedError)
    end
  end
end
