# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/omniauth_helpers'

RSpec.describe SessionsController, type: :request do
  include SignInOutRequestHelpers

  describe 'POST create' do
    subject(:post_create) do
      post "/auth/#{provider}?state=#{model}"
      follow_redirect!
    end

    let(:auth_hash) { Hashie::Mash.new(OmniauthHelpers.fixture_for_provider(provider)) }

    before do
      OmniAuth.config.add_mock(provider.to_sym, auth_hash)
    end

    context 'when model is user' do
      let(:model) { 'user' }

      UserAccount.providers.except(:developer).each_key do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          context 'when the user is signed out' do
            context 'when the account does not exist' do
              it 'creates a new account' do
                expect { post_create }.to change(UserAccount, :count).from(0).to(1)
              end

              it 'creates a new user' do
                expect { post_create }.to change(User, :count).from(0).to(1)
              end

              it 'logs the user in' do
                post_create

                expect(controller.send(:current_user)).not_to be_nil
              end

              it 'redirects to root' do
                post_create

                expect(controller).to redirect_to(root_path)
              end
            end

            context 'when the account exists' do
              before do
                create(:user_account, external_uid: auth_hash.uid, provider:)
              end

              it 'does not create a new account' do
                expect { post_create }.not_to change(UserAccount, :count).from(1)
              end

              it 'does not create a new user' do
                expect { post_create }.not_to change(User, :count).from(1)
              end

              it 'logs the user in' do
                post_create

                expect(controller.send(:current_user)).not_to be_nil
              end

              it 'redirects to root' do
                post_create

                expect(controller).to redirect_to(root_path)
              end
            end
          end

          context 'when user is signed in' do
            let(:user) do
              account_provider = UserAccount.providers.except(provider, :developer).keys.sample

              create(:user).tap do |user|
                create(:user_account, provider: account_provider, user:)
              end
            end

            before do
              sign_in(user)
              # This is required since `sign_in` mocks the OAuth response for
              # the current example but we want to test its behavior instead.
              OmniAuth.config.add_mock(provider.to_sym, auth_hash)
            end

            context 'when account does not exist' do
              context 'when user does not have account for provider' do
                it 'creates a new account' do
                  expect { post_create }.to change(UserAccount, :count).from(1).to(2)
                end

                it 'does not create a new user' do
                  expect { post_create }.not_to change(User, :count).from(1)
                end

                it 'associates the account with the current user' do
                  expect { post_create }.to change { user.reload.accounts.find_by(provider:) }
                    .from(nil).to(an_instance_of(UserAccount))
                end
              end

              context 'when user already has account for same provider' do
                before do
                  create(:user_account, provider:, user:)
                end

                it 'does not create a new account' do
                  expect { post_create }.not_to change(UserAccount, :count).from(2)
                end
              end
            end

            context 'when account exists' do
              context 'when account belongs to other user' do
                let!(:account) { create(:user_account, external_uid: auth_hash.uid, provider:) }

                it 'does not create a new account' do
                  expect { post_create }.not_to change(UserAccount, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { post_create }.not_to change(User, :count).from(2)
                end

                it 'associates the account with the current user' do
                  expect { post_create }.to change { account.reload.user }.from(account.user).to(user)
                end
              end

              context 'when account belongs to current user' do
                before do
                  create(:user_account, external_uid: auth_hash.uid, provider:, user:)
                end

                it 'does not create a new account' do
                  expect { post_create }.not_to change(UserAccount, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { post_create }.not_to change(User, :count).from(1)
                end
              end
            end
          end
        end
      end
    end

    context 'when model is brand' do
      let(:model) { 'brand' }

      BrandAccount.providers.except(:developer).each_key do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          context 'when user is not signed in' do
            it 'redirects to root' do
              post_create

              expect(controller).to redirect_to(root_path)
            end
          end

          context 'when user is signed in' do
            let(:user) { create(:user, :with_account) }

            before do
              sign_in(user)
            end

            context 'when brand exists' do
              let(:brand) { create(:brand) }

              before do
                brand.users << user
              end

              context 'when account does not exist' do
                before do
                  create(:brand_account, provider:, brand:)
                end

                it 'creates a new account' do
                  expect { post_create }.to change(BrandAccount, :count).from(1).to(2)
                end

                it 'does not create a new brand' do
                  expect { post_create }.not_to change(Brand, :count).from(1)
                end

                it 'associates the account with the current brand' do
                  expect { post_create }.to change { brand.reload.accounts.count }
                    .from(1).to(2)
                end
              end

              context 'when account exists' do
                context 'when account belongs to other brand' do
                  let!(:account) { create(:brand_account, external_uid: auth_hash.uid, provider:) }

                  it 'does not create a new account' do
                    expect { post_create }.not_to change(BrandAccount, :count).from(1)
                  end

                  it 'does not create a new user' do
                    expect { post_create }.not_to change(Brand, :count).from(2)
                  end

                  it 'associates the account with the current brand' do
                    expect { post_create }.to change { account.reload.brand }.from(account.brand).to(brand)
                  end
                end

                context 'when account belongs to current brand' do
                  before do
                    create(:brand_account, external_uid: auth_hash.uid, provider:, brand:)
                  end

                  it 'does not create a new account' do
                    expect { post_create }.not_to change(BrandAccount, :count).from(1)
                  end

                  it 'does not create a new brand' do
                    expect { post_create }.not_to change(Brand, :count).from(1)
                  end
                end
              end
            end

            context 'when brand does not exist' do
              context 'when the account does not exist' do
                it 'creates a new account' do
                  expect { post_create }.to change(BrandAccount, :count).from(0).to(1)
                end

                it 'creates a new user' do
                  expect { post_create }.to change(Brand, :count).from(0).to(1)
                end

                it 'associates the signed in user with the brand' do
                  expect { post_create }.to change { user.reload.brand }.from(nil).to(an_instance_of(Brand))
                end

                it 'redirects to root' do
                  post_create

                  expect(controller).to redirect_to(root_path)
                end
              end

              context 'when the account exists' do
                before do
                  create(:brand_account, external_uid: auth_hash.uid, provider:)
                end

                it 'does not create a new account' do
                  expect { post_create }.not_to change(BrandAccount, :count).from(1)
                end

                it 'does not create a new brand' do
                  expect { post_create }.not_to change(Brand, :count).from(1)
                end

                it 'associates the signed in user with the brand' do
                  expect { post_create }.to change { user.reload.brand }.from(nil).to(an_instance_of(Brand))
                end

                it 'redirects to root' do
                  post_create

                  expect(controller).to redirect_to(root_path)
                end
              end
            end
          end
        end
      end
    end
  end

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
      it 'redirects the user to login' do
        expect(delete_destroy).to redirect_to(login_path)
      end
    end
  end
end
