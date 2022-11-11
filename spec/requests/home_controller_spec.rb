# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe HomeController do
  include SignInOutRequestHelpers

  describe 'GET index' do
    subject(:get_index) { get '/' }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      it 'renders the home page' do
        get_index

        expect(response.body).to include("Woohoo, you're in")
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user to login' do
        expect(get_index).to redirect_to(login_path)
      end
    end
  end

  describe 'GET login' do
    subject(:get_login) { get '/login' }

    it 'renders the login page' do
      get_login

      expect(response.body).to include('Sign in')
    end
  end
end
