# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe SessionsController, type: :request do
  include SignInOutRequestHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete '/sign_out' }

    context 'when user is signed in' do
      before do
        sign_in(create(:user, :with_account))
      end

      it 'logs the user out' do
        expect { delete_destroy }.to change { controller.send(:user_signed_in?) }.from(true).to(false)
      end

      it 'sets the flash' do
        delete_destroy

        expect(controller.flash[:success]).to eq('You have been signed out.')
      end

      it 'redirects to root path' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end
end
