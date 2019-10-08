# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe OmniauthCallbacksController, type: :request do
  include SignInOutHelpers

  describe 'GET authenticate' do
    subject(:get_authenticate) do
      get "/auth/#{provider}?model=#{model}"
      follow_redirect!
    end

    let(:auth_hash) do
      fixture_name = case provider
                     when 'twitter'
                       'twitter_oauth_hash.json'
                     when 'google_oauth2'
                       'google_oauth_hash.json'
                     end
      JSON.parse(file_fixture(fixture_name).read, object_class: OpenStruct)
    end

    before do
      OmniAuth.config.add_mock(provider.to_sym, auth_hash)
    end

    context 'when model is user' do
      let(:model) { 'user' }

      %w[twitter google_oauth2].each do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          it 'redirects to root' do
            get_authenticate

            expect(controller).to redirect_to(root_path)
          end

          it 'sets the flash' do
            get_authenticate

            expect(controller.flash[:notice]).to eq('Successfully authenticated user.')
          end

          context 'when the account does not exist' do
            it 'creates a new account' do
              expect { get_authenticate }.to change(Account, :count).from(0).to(1)
            end

            it 'creates a new user' do
              expect { get_authenticate }.to change(User, :count).from(0).to(1)
            end

            it 'logs the user in' do
              get_authenticate

              expect(controller.send(:user_signed_in?)).to eq(true)
            end
          end

          context 'when the account exists' do
            before do
              FactoryBot.create(:account, external_uid: auth_hash.uid, provider: provider)
            end

            it 'does not create a new account' do
              expect { get_authenticate }.not_to change(Account, :count).from(1)
            end

            it 'does not create a new user' do
              expect { get_authenticate }.not_to change(User, :count).from(1)
            end

            it 'logs the user in' do
              get_authenticate

              expect(controller.send(:user_signed_in?)).to eq(true)
            end
          end

          context 'when user is logged in' do
            let(:user) do
              account_provider = (Account.providers.keys - [provider]).first

              FactoryBot.create(:user).tap do |user|
                FactoryBot.create(:account, provider: account_provider, user: user)
              end
            end

            before do
              sign_in(user)
              # This is required since `sign_in` mocks the OAuth response for
              # the current example but we want to test it instead.
              OmniAuth.config.add_mock(provider.to_sym, auth_hash)
            end

            # This is temporary until this spec is simplified
            # rubocop:disable RSpec/NestedGroups

            context 'when account does not exist' do
              it 'creates a new account' do
                expect { get_authenticate }.to change(Account, :count).from(1).to(2)
              end

              it 'does not create a new user' do
                expect { get_authenticate }.not_to change(User, :count).from(1)
              end

              it 'associates the account with the current user' do
                expect { get_authenticate }.to change { user.reload.public_send("#{provider}_account") }
                  .from(nil).to(an_instance_of(Account))
              end
            end

            context 'when account exists' do
              context 'when account belongs to someone else' do
                let!(:account) { FactoryBot.create(:account, external_uid: auth_hash.uid, provider: provider) }

                it 'does not create a new account' do
                  expect { get_authenticate }.not_to change(Account, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { get_authenticate }.not_to change(User, :count).from(2)
                end

                it 'associates the account with the current user' do
                  expect { get_authenticate }.to change { account.reload.user }.from(account.user).to(user)
                end
              end

              context 'when account belongs to current user' do
                before do
                  FactoryBot.create(:account, external_uid: auth_hash.uid, provider: provider, user: user)
                end

                it 'does not create a new account' do
                  expect { get_authenticate }.not_to change(Account, :count).from(2)
                end

                it 'does not create a new user' do
                  expect { get_authenticate }.not_to change(User, :count).from(1)
                end
              end
            end

            # rubocop:enable RSpec/NestedGroups
          end
        end
      end
    end

    context 'when model is brand' do
      let(:model) { 'brand' }
      let(:provider) { 'twitter' }

      context 'when user is logged in' do
        let(:user) { FactoryBot.create(:user, :with_account) }

        before do
          sign_in(user)
        end

        it 'redirects to root' do
          get_authenticate

          expect(controller).to redirect_to(root_path)
        end

        it 'sets the flash' do
          get_authenticate

          expect(controller.flash[:notice]).to eq('Successfully authenticated brand.')
        end

        context 'when brand does not exist' do
          it 'creates a new brand' do
            expect { get_authenticate }.to change(Brand, :count).from(0).to(1)
          end

          it 'associates the brand with the current user' do
            expect { get_authenticate }.to change { user.reload.brand }.from(nil).to(an_instance_of(Brand))
          end
        end

        context 'when brand exists' do
          let!(:brand) { FactoryBot.create(:brand, external_uid: auth_hash.uid) }

          it 'does not create a new brand' do
            expect { get_authenticate }.not_to change(Brand, :count).from(1)
          end

          it 'associates the brand with the current user' do
            expect { get_authenticate }.to change { user.reload.brand }.from(nil).to(brand)
          end
        end
      end

      context 'when user is not logged in' do
        it 'redirects to root' do
          get_authenticate

          expect(controller).to redirect_to(root_path)
        end

        it 'does not set the flash' do
          get_authenticate

          expect(controller.flash[:notice]).to be_nil
        end
      end
    end
  end
end
