# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe Brands::UsersController, type: :request do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }

  describe 'POST create' do
    subject(:post_create) { post "/brands/#{brand.id}/users", params: { user_id: user.id } }

    let(:user) { create(:user) }

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          brand.users << browsing_user
        end

        context 'when user does not belong to other brand' do
          it 'adds the user to the brand' do
            expect { post_create }.to change { user.reload.brand_id }.from(nil).to(brand.id)
          end

          it 'redirects to edit brand path' do
            post_create

            expect(response).to redirect_to(edit_brand_path(brand))
          end

          context 'when brand has subscription' do
            let(:paddle_client_class_spy) { class_spy(Paddle::Client, new: paddle_client_spy) }
            let(:paddle_client_spy) { instance_spy(Paddle::Client) }
            let!(:subscription) { create(:subscription, brand:) }

            before do
              stub_const('Paddle::Client', paddle_client_class_spy)
            end

            it 'updates quantity on subscription' do
              post_create

              expect(paddle_client_spy).to have_received(:change_quantity).with(subscription.external_uid,
                                                                                brand.users.count)
            end
          end
        end

        context 'when user belongs to other brand' do
          before do
            create(:brand).users << user
          end

          it 'does not add the user to the brand' do
            expect { post_create }.not_to change(user.reload, :brand_id)
          end

          it 'redirects to root path' do
            post_create

            expect(response).to redirect_to(root_path)
          end

          context 'when brand has subscription' do
            let(:paddle_client_class_spy) { class_spy(Paddle::Client) }

            before do
              create(:subscription, brand:)

              stub_const('Paddle::Client', paddle_client_class_spy)
            end

            it 'does not update subscription quantity' do
              post_create

              expect(paddle_client_class_spy).not_to have_received(:new)
            end
          end
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

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete "/brands/#{brand.id}/users/#{user.id}" }

    let(:user) { create(:user) }

    before do
      brand.users << user
    end

    context 'when user is signed in' do
      let(:browsing_user) { create(:user, :with_account) }

      before do
        sign_in(browsing_user)
      end

      context 'when user is authorized' do
        before do
          brand.users << browsing_user
        end

        shared_examples 'removes user from brand' do
          it 'removes the user from the brand' do
            expect { delete_destroy }.to change { user.reload.brand_id }.from(brand.id).to(nil)
          end

          it 'redirects back' do
            delete_destroy

            expect(response).to redirect_to(redirect_path)
          end

          context 'when brand has subscription' do
            let(:paddle_client_class_spy) { class_spy(Paddle::Client, new: paddle_client_spy) }
            let(:paddle_client_spy) { instance_spy(Paddle::Client) }
            let!(:subscription) { create(:subscription, brand:) }

            before do
              stub_const('Paddle::Client', paddle_client_class_spy)
            end

            it 'updates quantity on subscription' do
              delete_destroy

              expect(paddle_client_spy).to have_received(:change_quantity).with(subscription.external_uid,
                                                                                brand.users.count)
            end
          end
        end

        context 'when removing other user from brand' do
          include_examples 'removes user from brand' do
            let(:redirect_path) { edit_brand_path(brand) }
          end
        end

        context 'when user is removing self from brand' do
          let(:user) { browsing_user }

          include_examples 'removes user from brand' do
            let(:redirect_path) { root_path }
          end
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
