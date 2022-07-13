# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe Brands::Tickets::InternalNotesController, type: :request do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }
  let(:ticket) { create(:internal_ticket, brand:).base_ticket }

  describe 'POST create' do
    subject(:post_create) do
      post "/brands/#{brand.id}/tickets/#{ticket.id}/internal_notes", params: { internal_note: { content: } }
    end

    let(:content) { nil }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        context 'when brand has subscription' do
          before do
            create(:subscription, brand:)
          end

          let(:content) { 'does not matter' }

          it 'creates an internal note' do
            expect { post_create }.to change { ticket.internal_notes.count }.from(0).to(1)
          end

          it 'redirects to the ticket' do
            post_create

            expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
          end
        end

        context 'when brand does not have subscription' do
          include_examples 'unauthorized user examples', 'You do not have an active subscription.'
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end
end
