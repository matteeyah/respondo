# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Users::PersonalAccessTokensController, type: :request do
  include SignInOutRequestHelpers

  describe 'POST create' do
    subject(:post_create) { post "/users/#{user.id}/personal_access_tokens", params: { name: } }

    let(:name) { nil }
    let(:user) { create(:user, :with_account) }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          sign_out

          sign_in(user)
        end

        context 'when personal access token is valid' do
          let(:name) { 'something_nice' }

          it 'creates a new personal access token' do
            expect { post_create }.to change(PersonalAccessToken, :count).from(0).to(1)
          end

          it 'redirects to edit user path' do
            post_create

            expect(response).to redirect_to(edit_user_path(user))
          end
        end

        context 'when personal access token is duplicate' do
          let(:name) { 'something_nice' }

          before do
            create(:personal_access_token, name:, user:)
          end

          it 'does not create a new personal access token' do
            expect { post_create }.not_to change(PersonalAccessToken, :count).from(1)
          end

          it 'redirects to edit user path' do
            post_create

            expect(response).to redirect_to(edit_user_path(user))
          end
        end

        context 'when personal access token does not have name' do
          let(:name) { nil }

          it 'does not create a new personal access token' do
            expect { post_create }.not_to change(PersonalAccessToken, :count).from(0)
          end

          it 'redirects to edit user path' do
            post_create

            expect(response).to redirect_to(edit_user_path(user))
          end
        end
      end

      context 'when user is not authorized' do
        it 'redirects the user back (to root)' do
          expect(post_create).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(post_create).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/users/#{user.id}/personal_access_tokens/#{personal_access_token.id}" }

    let(:user) { create(:user, :with_account) }
    let!(:personal_access_token) { create(:personal_access_token, user:) }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          sign_out

          sign_in(user)
        end

        it 'destroys the personal access token' do
          expect { delete_destroy }.to change(PersonalAccessToken, :count).from(1).to(0)
        end

        it 'redirects to edit user path' do
          delete_destroy

          expect(response).to redirect_to(edit_user_path(user))
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
