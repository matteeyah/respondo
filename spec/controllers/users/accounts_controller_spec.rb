# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe Users::AccountsController, type: :controller do
  include SignInOutHelpers

  let(:user) { FactoryBot.create(:user) }

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete :destroy, params: { user_id: user.id, id: account.id } }

    let!(:account) { FactoryBot.create(:account, user: user) }

    context 'when user is authorized' do
      before do
        sign_in(user)
      end

      it 'removes the user from the brand' do
        expect { delete_destroy }.to change(Account, :count).from(1).to(0)
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(delete_destroy.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end
  end
end
