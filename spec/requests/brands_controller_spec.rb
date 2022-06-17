# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe BrandsController, type: :request do
  include SignInOutRequestHelpers

  describe 'GET edit' do
    subject(:get_edit) { get "/brands/#{brand.id}/edit" }

    let(:brand) { create(:brand) }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        it 'renders the add user button' do
          get_edit

          expect(response.body).to include('Add User')
        end

        it 'renders the remove user link' do
          get_edit

          expect(response.body).to include("Remove #{CGI.escape_html(user.name)}")
        end

        context 'when pagination is not required' do
          it 'renders the users list' do
            get_edit

            expect(response.body).to include(CGI.escape_html(user.name))
          end
        end

        context 'when pagination is required' do
          let!(:extra_users) { create_list(:user, 20, brand:) }

          it 'paginates users' do
            get_edit

            expect(response.body).to include(*[user, *extra_users.first(19)].map { |user| CGI.escape_html(user.name) })
          end

          it 'does not show page two users' do
            get_edit

            expect(response.body).not_to include(CGI.escape_html(extra_users.last.name))
          end
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

  describe 'PATCH update' do
    subject(:patch_update) { patch "/brands/#{brand.id}", params: { brand: { domain: new_domain } } }

    let(:brand) { create(:brand) }
    let(:new_domain) { nil }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        context 'when the specified domain is valid' do
          let(:new_domain) { 'example.com' }

          it 'updates the brand' do
            expect { patch_update }.to change { brand.reload.domain }.from(nil).to(new_domain)
          end

          it 'sets the flash' do
            patch_update

            expect(controller.flash[:success]).to eq('Brand was successfully updated.')
          end

          it 'redirects to edit brand path' do
            patch_update

            expect(response).to redirect_to(edit_brand_path(brand))
          end
        end

        context 'when the specified domain is not valid' do
          let(:new_domain) { 'not!valid.com' }

          it 'does not update the brand' do
            expect { patch_update }.not_to change { brand.reload.domain }.from(nil)
          end

          it 'sets the flash' do
            patch_update

            expect(controller.flash[:danger]).to eq('Brand could not be updated.')
          end

          it 'redirects to edit brand path' do
            patch_update

            expect(response).to redirect_to(edit_brand_path(brand))
          end
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
