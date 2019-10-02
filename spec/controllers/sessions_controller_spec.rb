# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe SessionsController, type: :controller do
  include SignInOutHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete :destroy }

    context 'when user is not signed in' do
      it 'redirects the user' do
        expect(delete_destroy).to redirect_to(root_path)
      end

      it 'sets the flash' do
        delete_destroy

        expect(controller).to set_flash[:alert].to('You are not logged in.')
      end
    end

    context 'when user is signed in' do
      before do
        sign_in(FactoryBot.create(:user))
      end

      it 'redirects back to root' do
        expect(delete_destroy).to redirect_to(root_path)
      end

      it 'logs the user out' do
        expect { delete_destroy }.to change { controller.send(:user_signed_in?) }.from(true).to(false)
      end
    end
  end
end
