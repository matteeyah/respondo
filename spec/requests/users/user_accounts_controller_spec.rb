# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Users::UserAccountsController do
  include SignInOutRequestHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/users/#{user.id}/user_accounts/#{account.id}" }

    let(:user) { create(:user) }
    let!(:account) { create(:user_account, provider: 'google_oauth2', user:) }

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

        context 'when user has only one account' do
          it 'does not destroy the account' do
            expect { delete_destroy }.not_to change(UserAccount, :count).from(2)
          end

          it 'redirects to edit user path' do
            delete_destroy

            expect(response).to redirect_to(edit_user_path(user))
          end
        end

        context 'when user has multiple accounts' do
          before do
            create(:user_account, provider: 'activedirectory', user:)
          end

          it 'destroys the account' do
            expect { delete_destroy }.to change { UserAccount.exists?(account.id) }.from(true).to(false)
          end

          it 'redirects to edit user path' do
            delete_destroy

            expect(response).to redirect_to(edit_user_path(user))
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
      it 'redirects the user back (to login)' do
        expect(delete_destroy).to redirect_to(login_path)
      end
    end
  end
end
