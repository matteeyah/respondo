# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'
require './spec/support/unauthenticated_user_examples.rb'

RSpec.describe SessionsController, type: :request do
  include SignInOutHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete '/logout' }

    context 'when user is signed in' do
      before do
        sign_in(FactoryBot.create(:user, :with_account))
      end

      it 'logs the user out' do
        expect { delete_destroy }.to change { controller.send(:user_signed_in?) }.from(true).to(false)
      end

      it 'redirects to root path' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthenticated user examples'
    end
  end
end
