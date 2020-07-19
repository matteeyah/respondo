# frozen_string_literal: true

require './spec/support/concerns/models/ticketable_examples'

RSpec.describe InternalTicket, type: :model do
  it_behaves_like 'ticketable'

  describe '#actual_provider' do
    subject(:actual_provider) { internal_ticket.actual_provider }

    let(:internal_ticket) { FactoryBot.create(:internal_ticket) }

    it { is_expected.to eq(internal_ticket.base_ticket.provider) }
  end
end
