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

      it 'destroys the account' do
        expect { delete_destroy }.to change(Account, :count).from(1).to(0)
      end

      it 'sets the flash' do
        delete_destroy

        expect(controller).to set_flash[:notice].to('Successfully deleted the account.')
      end

      context 'when account removal fails' do
        let(:account_double) { instance_double(Account, id: 1, destroy: false) }

        before do
          allow(controller).to receive(:account).and_return(account_double)
        end

        it 'sets the flash' do
          delete_destroy

          expect(controller).to set_flash[:notice].to('There was a problem destroying the account.')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(delete_destroy.request).to set_flash[:alert].to('You are not allowed to edit the user.')
      end

      it 'redirects the user' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end
  end
end
