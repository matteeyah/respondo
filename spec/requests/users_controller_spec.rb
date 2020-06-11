# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers.rb'
require './spec/support/unauthorized_user_examples.rb'

RSpec.describe UsersController, type: :request do
  include SignInOutRequestHelpers

  describe 'GET edit' do
    subject(:get_edit) { get "/users/#{user.id}/edit" }

    let(:user) { FactoryBot.create(:user, :with_account) }

    context 'when user is signed in' do
      let(:browsing_user) { FactoryBot.create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          sign_out

          sign_in(user)
        end

        it 'renders the user account removal link' do
          get_edit

          expect(response.body).to include('Remove Google')
        end

        it 'renders the twitter authorization link' do
          get_edit

          expect(response.body).to include('Authorize Twitter')
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end
end
