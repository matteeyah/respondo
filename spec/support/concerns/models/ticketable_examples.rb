# frozen_string_literal: true

RSpec.shared_examples 'ticketable' do
  describe 'Relations' do
    subject(:ticketable) { create(described_class.to_s.underscore) }

    it { is_expected.to have_one(:base_ticket).dependent(:destroy) }
  end
end
