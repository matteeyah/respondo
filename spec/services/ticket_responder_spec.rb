# frozen_string_literal: true

RSpec.describe TicketResponder, type: :service do
  let(:service) { described_class.new(ticket, response, user) }
  let(:user) { FactoryBot.create(:user) }
  let(:response) { 'Sample response' }

  describe '#call' do
    subject(:call) { service.call }

    let(:ticket_creator_class) { class_spy(TicketCreator, new: spy) }
    let(:client_spy) { instance_spy(Clients::Client, reply: client_response) }

    before do
      stub_const('TicketCreator', ticket_creator_class)
    end

    context 'when ticket is internal' do
      let(:ticket) { FactoryBot.create(:internal_ticket).base_ticket }
      let(:client_response) { JSON.parse(file_fixture('disqus_post_hash.json').read).merge(raw_message: response).deep_symbolize_keys }

      context 'when authorized as user' do
        before do
          allow(user).to receive(:client_for_provider).with(ticket.provider).and_return(client_spy)
        end

        it 'calls TicketCreator service' do
          call

          expect(ticket_creator_class).to have_received(:new).with(
            ticket.provider, hash_including(raw_message: response), ticket.brand, user
          )
        end
      end

      context 'when authorized as brand' do
        before do
          user.update(brand: ticket.brand)

          allow(user.brand).to receive(:client_for_provider).with(ticket.provider).and_return(client_spy)
        end

        it 'calls TicketCreator service' do
          call

          expect(ticket_creator_class).to have_received(:new).with(
            ticket.provider, hash_including(raw_message: response), ticket.brand, user
          )
        end
      end
    end

    context 'when ticket is external' do
      let(:ticket) { FactoryBot.create(:external_ticket).base_ticket }
      let(:client_response) { JSON.parse(file_fixture('external_post_hash.json').read).merge(content: response).to_json }

      before do
        allow(Clients::External).to receive(:new).with(
          ticket.external_ticket.response_url, ticket.author.external_uid, ticket.author.username
        ).and_return(client_spy)
      end

      it 'calls TicketCreator service' do
        call

        expect(ticket_creator_class).to have_received(:new).with(
          ticket.provider, hash_including(content: response), ticket.brand, user
        )
      end
    end
  end
end
