# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers.rb'

RSpec.describe OmniauthCallbacksController, type: :request do
  include SignInOutRequestHelpers

  describe 'POST authenticate' do
    subject(:post_authenticate) do
      post "/auth/#{provider}?state=#{model}"
      follow_redirect!
    end

    let(:auth_hash) do
      fixture_name = case provider
                     when 'twitter'
                       'twitter_oauth_hash.json'
                     when 'google_oauth2'
                       'google_oauth_hash.json'
                     when 'disqus'
                       'disqus_oauth_hash.json'
                     end
      JSON.parse(file_fixture(fixture_name).read, object_class: OpenStruct)
    end

    before do
      OmniAuth.config.add_mock(provider.to_sym, auth_hash)
    end

    context 'when model is user' do
      let(:model) { 'user' }

      UserAccount.providers.each_key do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          context 'when the user is signed out' do
            context 'when the account does not exist' do
              it 'creates a new account' do
                expect { post_authenticate }.to change(UserAccount, :count).from(0).to(1)
              end

              it 'creates a new user' do
                expect { post_authenticate }.to change(User, :count).from(0).to(1)
              end

              it 'logs the user in' do
                post_authenticate

                expect(controller.send(:user_signed_in?)).to eq(true)
              end

              it 'sets the flash' do
                post_authenticate

                expect(controller.flash[:success]).to eq('User was successfully authenticated.')
              end

              it 'redirects to root' do
                post_authenticate

                expect(controller).to redirect_to(root_path)
              end
            end

            context 'when the account exists' do
              before do
                FactoryBot.create(:user_account, external_uid: auth_hash.uid, provider: provider)
              end

              it 'does not create a new account' do
                expect { post_authenticate }.not_to change(UserAccount, :count).from(1)
              end

              it 'does not create a new user' do
                expect { post_authenticate }.not_to change(User, :count).from(1)
              end

              it 'logs the user in' do
                post_authenticate

                expect(controller.send(:user_signed_in?)).to eq(true)
              end

              it 'sets the flash' do
                post_authenticate

                expect(controller.flash[:success]).to eq('User was successfully authenticated.')
              end

              it 'redirects to root' do
                post_authenticate

                expect(controller).to redirect_to(root_path)
              end
            end
          end

          context 'when user is signed in' do
            let(:user) do
              account_provider = (UserAccount.providers.keys - [provider]).first

              FactoryBot.create(:user).tap do |user|
                FactoryBot.create(:user_account, provider: account_provider, user: user)
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
                  expect { post_authenticate }.to change(UserAccount, :count).from(1).to(2)
                end

                it 'does not create a new user' do
                  expect { post_authenticate }.not_to change(User, :count).from(1)
                end

                it 'associates the account with the current user' do
                  expect { post_authenticate }.to change { user.reload.accounts.find_by(provider: provider) }
                    .from(nil).to(an_instance_of(UserAccount))
                end
              end

              context 'when user already has account for same provider' do
                before do
                  FactoryBot.create(:user_account, provider: provider, user: user)
                end

                it 'does not create a new account' do
                  expect { post_authenticate }.not_to change(UserAccount, :count).from(2)
                end

                it 'sets the flash' do
                  post_authenticate

                  expect(controller.flash[:danger]).to start_with('Could not authenticate user.')
                end
              end
            end

            context 'when account exists' do
              context 'when account belongs to other user' do
                let!(:account) { FactoryBot.create(:user_account, external_uid: auth_hash.uid, provider: provider) }

                it 'does not create a new account' do
                  expect { post_authenticate }.not_to change(UserAccount, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { post_authenticate }.not_to change(User, :count).from(2)
                end

                it 'associates the account with the current user' do
                  expect { post_authenticate }.to change { account.reload.user }.from(account.user).to(user)
                end
              end

              context 'when account belongs to current user' do
                before do
                  FactoryBot.create(:user_account, external_uid: auth_hash.uid, provider: provider, user: user)
                end

                it 'does not create a new account' do
                  expect { post_authenticate }.not_to change(UserAccount, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { post_authenticate }.not_to change(User, :count).from(1)
                end
              end
            end
          end
        end
      end
    end

    context 'when model is brand' do
      let(:model) { 'brand' }

      BrandAccount.providers.each_key do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          context 'when user is not signed in' do
            it 'redirects to root' do
              post_authenticate

              expect(controller).to redirect_to(root_path)
            end

            it 'sets the flash' do
              post_authenticate

              expect(controller.flash[:warning]).to eq('User is not signed in.')
            end
          end

          context 'when user is signed in' do
            let(:user) { FactoryBot.create(:user, :with_account) }

            before do
              sign_in(user)
            end

            context 'when brand exists' do
              let(:brand) { FactoryBot.create(:brand) }

              before do
                brand.users << user
              end

              context 'when account does not exist' do
                context 'when brand does not have account for provider' do
                  it 'creates a new account' do
                    expect { post_authenticate }.to change(BrandAccount, :count).from(0).to(1)
                  end

                  it 'does not create a new brand' do
                    expect { post_authenticate }.not_to change(Brand, :count).from(1)
                  end

                  it 'associates the account with the current brand' do
                    expect { post_authenticate }.to change { brand.reload.accounts.find_by(provider: provider) }
                      .from(nil).to(an_instance_of(BrandAccount))
                  end
                end

                context 'when brand already has account for same provider' do
                  before do
                    FactoryBot.create(:brand_account, provider: provider, brand: brand)
                  end

                  it 'does not create a new account' do
                    expect { post_authenticate }.not_to change(BrandAccount, :count).from(1)
                  end

                  it 'sets the flash' do
                    post_authenticate

                    expect(controller.flash[:danger]).to start_with('Could not authenticate brand.')
                  end
                end
              end

              context 'when account exists' do
                context 'when account belongs to other brand' do
                  let!(:account) { FactoryBot.create(:brand_account, external_uid: auth_hash.uid, provider: provider) }

                  it 'does not create a new account' do
                    expect { post_authenticate }.not_to change(BrandAccount, :count).from(1)
                  end

                  it 'does not create a new user' do
                    expect { post_authenticate }.not_to change(Brand, :count).from(2)
                  end

                  it 'associates the account with the current brand' do
                    expect { post_authenticate }.to change { account.reload.brand }.from(account.brand).to(brand)
                  end
                end

                context 'when account belongs to current brand' do
                  before do
                    FactoryBot.create(:brand_account, external_uid: auth_hash.uid, provider: provider, brand: brand)
                  end

                  it 'does not create a new account' do
                    expect { post_authenticate }.not_to change(BrandAccount, :count).from(1)
                  end

                  it 'does not create a new brand' do
                    expect { post_authenticate }.not_to change(Brand, :count).from(1)
                  end
                end
              end
            end

            context 'when brand does not exist' do
              context 'when the account does not exist' do
                it 'creates a new account' do
                  expect { post_authenticate }.to change(BrandAccount, :count).from(0).to(1)
                end

                it 'creates a new user' do
                  expect { post_authenticate }.to change(Brand, :count).from(0).to(1)
                end

                it 'associates the signed in user with the brand' do
                  expect { post_authenticate }.to change { user.reload.brand }.from(nil).to(an_instance_of(Brand))
                end

                it 'sets the flash' do
                  post_authenticate

                  expect(controller.flash[:success]).to eq('Brand was successfully authenticated.')
                end

                it 'redirects to root' do
                  post_authenticate

                  expect(controller).to redirect_to(root_path)
                end
              end

              context 'when the account exists' do
                before do
                  FactoryBot.create(:brand_account, external_uid: auth_hash.uid, provider: provider)
                end

                it 'does not create a new account' do
                  expect { post_authenticate }.not_to change(BrandAccount, :count).from(1)
                end

                it 'does not create a new brand' do
                  expect { post_authenticate }.not_to change(Brand, :count).from(1)
                end

                it 'associates the signed in user with the brand' do
                  expect { post_authenticate }.to change { user.reload.brand }.from(nil).to(an_instance_of(Brand))
                end

                it 'sets the flash' do
                  post_authenticate

                  expect(controller.flash[:success]).to eq('Brand was successfully authenticated.')
                end

                it 'redirects to root' do
                  post_authenticate

                  expect(controller).to redirect_to(root_path)
                end
              end
            end
          end
        end
      end
    end
  end
end
