# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::BrandAccountsController, type: :request do
  include SignInOutRequestHelpers

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/brands/#{brand.id}/brand_accounts/#{account.id}" }

    let(:brand) { create(:brand) }
    let!(:account) { create(:brand_account, provider: 'twitter', brand:) }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          brand.users << browsing_user
        end

        it 'destroys the account' do
          expect { delete_destroy }.to change(BrandAccount, :count).from(1).to(0)
        end

        it 'redirects to edit brand path' do
          delete_destroy

          expect(response).to redirect_to(edit_brand_path(brand))
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(delete_destroy).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(delete_destroy).to redirect_to(root_path)
      end
    end
  end
end
