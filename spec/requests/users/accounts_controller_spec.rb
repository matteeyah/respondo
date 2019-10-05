# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe Users::AccountsController, type: :request do
  include SignInOutHelpers

  let(:user) { FactoryBot.create(:user) }

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/users/#{user.id}/accounts/#{account.id}" }

    let!(:account) { FactoryBot.create(:account, user: user) }

    context 'when user is authorized' do
      before do
        sign_in(user)
      end

      it 'destroys the account' do
        expect { delete_destroy }.to change(Account, :count).from(1).to(0)
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
end
