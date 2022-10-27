# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::Tickets::TagsController do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }
  let(:ticket) { create(:internal_ticket, brand:).base_ticket }

  describe 'POST create' do
    subject(:post_create) do
      post "/brands/#{brand.id}/tickets/#{ticket.id}/tags", params: { acts_as_taggable_on_tag: { name: } }
    end

    let(:name) { nil }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        context 'when parameters are valid' do
          let(:name) { 'hello' }

          it 'tags the ticket' do
            expect { post_create }.to change { ticket.reload.tag_list }.from([]).to(%w[hello])
          end

          it 'redirects to the ticket' do
            post_create

            expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
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

  describe 'DELETE destroy' do
    subject(:delete_destroy) do
      delete "/brands/#{brand.id}/tickets/#{ticket.id}/tags/#{tag.id}", params: { acts_as_taggable_on_tag: { id: } }
    end

    let(:id) { nil }
    let(:tag) { ActsAsTaggableOn::Tag.create(name: 'hello') }

    before do
      ticket.tags << tag
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

        context 'when parameters are valid' do
          let(:id) { tag.id }

          it 'removes the tag from the ticket' do
            expect { delete_destroy }.to change { ticket.reload.tag_list }.from(%w[hello]).to([])
          end

          it 'redirects to the ticket' do
            delete_destroy

            expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
          end
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(delete_destroy).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end
  end
end
