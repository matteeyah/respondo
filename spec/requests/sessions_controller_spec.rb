# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe SessionsController, type: :request do
  include SignInOutHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete '/logout' }

    context 'when user is not signed in' do
      it 'redirects the user' do
        expect(delete_destroy).to redirect_to(root_path)
      end

      it 'sets the flash' do
        delete_destroy
        follow_redirect!

        expect(controller.flash[:alert]).to eq('You are not logged in.')
      end
    end

    context 'when user is signed in' do
      before do
        sign_in(FactoryBot.create(:user, :with_account))
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
