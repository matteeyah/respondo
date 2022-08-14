# frozen_string_literal: true

RSpec.describe TicketResponder, type: :service do
  let(:service) { described_class.new(ticket, response, user) }
  let(:user) { create(:user) }
  let(:response) { 'Sample response' }

  describe '#call' do
    subject(:call) { service.call }

    let(:ticket_creator_class) { class_spy(TicketCreator, new: spy) }
    let(:client_spy) { instance_spy(Clients::Client, reply: 'response') }
    let(:ticket) { create(:internal_ticket).base_ticket }

    before do
      stub_const('TicketCreator', ticket_creator_class)

      allow(ticket).to receive(:client).and_return(client_spy)
    end

    it 'calls TicketCreator service' do
      call

      expect(ticket_creator_class).to have_received(:new).with(
        ticket.provider, 'response', ticket.source, user
      )
    end
  end
end
