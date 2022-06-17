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
        expect { delete_destroy }.to change { controller.send(:current_user) }.from(anything).to(nil)
      end

      it 'redirects to login path' do
        expect(delete_destroy).to redirect_to(login_path)
      end
    end

    context 'when user is not signed in' do
      it 'sets the alert flash' do
        delete_destroy
        follow_redirect!

        expect(controller.flash[:warning]).to eq('You are not signed in.')
      end

      it 'redirects the user to login' do
        expect(delete_destroy).to redirect_to(login_path)
      end
    end
  end
end
