# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers.rb'
require './spec/support/unauthenticated_user_examples.rb'
require './spec/support/unauthorized_user_examples.rb'

RSpec.describe Users::AccountsController, type: :request do
  include SignInOutRequestHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/users/#{user.id}/accounts/#{account.id}" }

    let(:user) { FactoryBot.create(:user) }
    let!(:account) { FactoryBot.create(:account, provider: 'google_oauth2', user: user) }

    context 'when user is signed in' do
      let(:browsing_user) { FactoryBot.create(:user, :with_account) }

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
            expect { delete_destroy }.not_to change(Account, :count).from(2)
          end

          it 'sets the flash' do
            delete_destroy

            expect(controller.flash[:danger]).to eq('You can not remove your last account.')
          end

          it 'redirects to edit user path' do
            delete_destroy

            expect(response).to redirect_to(edit_user_path(user))
          end
        end

        context 'when user has multiple accounts' do
          before do
            FactoryBot.create(:account, provider: 'twitter', user: user)
          end

          it 'destroys the account' do
            expect { delete_destroy }.to change(Account, :count).from(3).to(2)
          end

          it 'sets the flash' do
            delete_destroy

            expect(controller.flash[:success]).to eq('User account was successfully deleted.')
          end

          it 'redirects to edit user path' do
            delete_destroy

            expect(response).to redirect_to(edit_user_path(user))
          end
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not allowed to edit the user.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthenticated user examples'
    end
  end
end
