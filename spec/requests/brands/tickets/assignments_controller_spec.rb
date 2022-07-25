# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::Tickets::AssignmentsController, type: :request do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }
  let(:ticket) { create(:internal_ticket, brand:).base_ticket }

  describe 'PATCH update' do
    subject(:post_update) do
      post "/brands/#{brand.id}/tickets/#{ticket.id}/assignments",
           params: { ticket: { assignment_attributes: { user_id: } } }
    end

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        let(:user_id) { create(:user, brand:).id }

        before do
          brand.users << user
        end

        it 'assigns the ticket' do
          expect { post_update }.to change { ticket.reload.assignment }.from(nil).to(an_instance_of(Assignment))
        end

        it 'creates an assignment' do
          expect { post_update }.to change(Assignment, :count).from(0).to(1)
        end

        it 'redirects to the ticket' do
          post_update

          expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
        end

        context 'when there is an assignee' do
          before do
            create(:assignment, user: create(:user, brand:), ticket:)
          end

          it 'updates the assignment to the specified user' do
            expect { post_update }.to change { ticket.assignment.reload.user.id }.to(user_id)
          end

          it 'does not create additional assignments' do
            expect { post_update }.not_to change(Assignment, :count).from(1)
          end
        end
      end

      context 'when user is not authorized' do
        let(:user_id) { nil }

        it 'redirects the user back (to root)' do
          expect(post_update).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      let(:user_id) { nil }

      it 'redirects the user back (to root)' do
        expect(post_update).to redirect_to(root_path)
      end
    end
  end
end
