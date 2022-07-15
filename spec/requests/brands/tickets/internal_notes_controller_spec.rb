# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::Tickets::InternalNotesController, type: :request do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }
  let(:ticket) { create(:internal_ticket, brand:).base_ticket }

  describe 'POST create' do
    subject(:post_create) do
      post "/brands/#{brand.id}/tickets/#{ticket.id}/internal_notes",
           params: { internal_note: { content: 'does not matter' } }
    end

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

          it 'creates an internal note' do
            expect { post_create }.to change { ticket.internal_notes.count }.from(0).to(1)
          end

          it 'redirects to the ticket' do
            post_create

            expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
          end
        end

        context 'when brand does not have subscription' do
          it 'redirects the user back (to root)' do
            expect(post_create).to redirect_to(root_path)
          end
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(post_create).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(post_create).to redirect_to(root_path)
      end
    end
  end
end
