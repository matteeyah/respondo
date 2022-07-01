# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe HomeController, type: :request do
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

        expect(response.body).to include('Welcome to Respondo')
      end
    end

    context 'when user is not signed in' do
      it 'sets the alert flash' do
        get_index
        follow_redirect!

        expect(controller.flash[:warning]).to eq('You are not signed in.')
      end

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
