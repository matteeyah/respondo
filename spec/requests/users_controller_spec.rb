# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe UsersController do
  include SignInOutRequestHelpers

  describe 'GET edit' do
    subject(:get_edit) { get "/users/#{user.id}/edit" }

    let(:user) { create(:user, :with_account) }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          sign_out

          sign_in(user)
        end

        it 'renders the edit page' do
          get_edit

          expect(response.body).to include(user.name)
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(get_edit).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to login)' do
        expect(get_edit).to redirect_to(login_path)
      end
    end
  end
end
