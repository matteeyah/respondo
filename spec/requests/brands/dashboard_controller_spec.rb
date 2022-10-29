# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::DashboardController do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }

  describe 'GET index' do
    subject(:get_index) { get "/brands/#{brand.id}/dashboard" }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        it 'shows the dashboard' do
          get_index

          expect(response.body).to include(
            "Welcome #{user.name}, you're all set! Feel free to hop into the brand tickets!"
          )
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(get_index).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(get_index).to redirect_to(root_path)
      end
    end
  end
end
