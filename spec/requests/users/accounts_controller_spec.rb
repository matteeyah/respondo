# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'
require './spec/support/unauthenticated_user_examples.rb'

RSpec.describe Users::AccountsController, type: :request do
  include SignInOutHelpers

  let(:user) { FactoryBot.create(:user) }

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/users/#{user.id}/accounts/#{account.id}" }

    let!(:account) { FactoryBot.create(:account, user: user) }

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

        it 'destroys the account' do
          expect { delete_destroy }.to change(Account, :count).from(2).to(1)
        end

        it 'sets the flash' do
          delete_destroy

          expect(controller.flash[:notice]).to eq('Successfully deleted the account.')
        end
      end

      context 'when user is not authorized' do
        it 'sets the flash' do
          delete_destroy

          expect(controller.flash[:alert]).to eq('You are not allowed to edit the user.')
        end

        it 'redirects the user' do
          expect(delete_destroy).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthenticated user examples'
    end
  end
end
