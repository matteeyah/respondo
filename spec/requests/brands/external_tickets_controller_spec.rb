# frozen_string_literal: true

RSpec.describe Brands::ExternalTicketsController, type: :request do
  let(:brand) { FactoryBot.create(:brand) }

  describe 'POST create.json' do
    subject(:post_create_json) { post "/brands/#{brand.id}/external_tickets.json", params: external_json }

    let(:external_json) do
      {
        external_uid: '123hello321world',
        content: 'This is content from the external ticket example.',
        parent_uid: 'external_ticket_parent_external_uid',
        author: {
          external_uid: 'external_ticket_author_external_uid',
          username: 'best_username'
        }
      }
    end

    it 'creates a ticket' do
      expect { post_create_json }.to change(Ticket, :count).from(0).to(1)
    end

    it 'creates a ticket with matching attributes' do
      post_create_json

      expect(Ticket.find_by(external_uid: external_json[:external_uid])).to have_attributes(content: external_json[:content])
    end

    it 'renders json' do
      post_create_json

      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'renders new ticket' do
      post_create_json

      expect(response.body).to eq(Ticket.find_by(external_uid: external_json[:external_uid]).to_json)
    end
  end
end
