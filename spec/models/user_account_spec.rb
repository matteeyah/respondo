# frozen_string_literal: true

require './spec/support/concerns/models/accountable_examples.rb'

RSpec.describe UserAccount, type: :model do
  describe 'Validations' do
    subject(:account) { FactoryBot.create(:user_account) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:provider).scoped_to(:user_id).ignoring_case_sensitivity }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider).ignoring_case_sensitivity }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[google_oauth2 twitter disqus]) }

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
  end

  it_behaves_like 'accountable'

  describe '.from_omniauth' do
    described_class.providers.keys.each do |provider|
      context "when provider is #{provider}" do
        subject(:from_omniauth) { described_class.from_omniauth(auth_hash, current_user) }

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

        context 'when there is no matching account' do
          context 'when creating a new user' do
            let(:current_user) { nil }

            it 'returns a new account' do
              expect(from_omniauth).to be_an_instance_of(described_class)
            end

            it 'builds an account entity with correct information' do
              expect(from_omniauth).to have_attributes(
                external_uid: auth_hash.uid, provider: provider,
                token: auth_hash.credentials.token, secret: auth_hash.credentials.secret,
                email: auth_hash.info.email
              )
            end

            it 'persists the new account' do
              expect(from_omniauth).to be_persisted
            end

            it 'creates a new user' do
              expect { from_omniauth }.to change(User, :count).from(0).to(1)
            end

            context 'when the user email belongs to brand domain' do
              let!(:brand) { FactoryBot.create(:brand, domain: 'example.com') }

              before do
                auth_hash.info.email = 'test@example.com'
              end

              it 'adds the user to the brand' do
                expect(from_omniauth.user.brand).to eq(brand)
              end
            end
          end

          context 'when adding the account to existing user' do
            let!(:current_user) { FactoryBot.create(:user) }

            context 'when existing user does not have account for provider' do
              it 'returns a new account' do
                expect(from_omniauth).to be_an_instance_of(described_class)
              end

              it 'builds an account entity with correct information' do
                expect(from_omniauth).to have_attributes(
                  external_uid: auth_hash.uid, provider: provider,
                  token: auth_hash.credentials.token, secret: auth_hash.credentials.secret,
                  email: auth_hash.info.email
                )
              end

              it 'persists the new account' do
                expect(from_omniauth).to be_persisted
              end

              it 'does not create new users' do
                expect { from_omniauth }.not_to change(User, :count).from(1)
              end

              it 'adds the account to the specified user' do
                expect(current_user.accounts).to include(from_omniauth)
              end

              context 'when the user email belongs to brand domain' do
                let!(:brand) { FactoryBot.create(:brand, domain: 'example.com') }

                before do
                  auth_hash.info.email = 'test@example.com'
                end

                it 'adds the user to the brand' do
                  expect(from_omniauth.user.brand).to eq(brand)
                end
              end
            end

            context 'when existing user has account for provider' do
              before do
                FactoryBot.create(:user_account, provider: provider, user: current_user)
              end

              it 'does not create new users' do
                expect { from_omniauth }.not_to change(User, :count).from(1)
              end

              it 'does not add the account to the specified user' do
                expect(current_user.accounts).not_to include(from_omniauth)
              end

              it 'has an error about provider being taken' do
                expect(from_omniauth.errors.details).to include(provider: array_including(a_hash_including(error: :taken)))
              end

              context 'when the user email belongs to brand domain' do
                let!(:brand) { FactoryBot.create(:brand, domain: 'example.com') }

                before do
                  auth_hash.info.email = 'test@example.com'
                end

                it 'adds the user to the brand' do
                  expect(from_omniauth.user.brand).to eq(brand)
                end
              end
            end
          end
        end

        context 'when there is a matching account' do
          let!(:account) { FactoryBot.create(:user_account, external_uid: auth_hash.uid, provider: auth_hash.provider) }
          let(:current_user) { account.user }

          context 'when account belongs to current user' do
            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'does not change the account owner' do
              expect { from_omniauth }.not_to change { account.reload.user }.from(account.user)
            end

            context 'when the user email belongs to brand domain' do
              let!(:brand) { FactoryBot.create(:brand, domain: 'example.com') }

              before do
                auth_hash.info.email = 'test@example.com'
              end

              it 'adds the user to the brand' do
                expect(from_omniauth.user.brand).to eq(brand)
              end
            end
          end

          context 'when switching account from different user' do
            let!(:current_user) { FactoryBot.create(:user) }

            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'removes the account from existing user' do
              previous_user = account.user

              expect { from_omniauth }.to change { previous_user.reload.accounts.find_by(provider: provider) }.from(account).to(nil)
            end

            it 'associates the account to current user' do
              expect(from_omniauth.user).to eq(current_user)
            end

            context 'when the user email belongs to brand domain' do
              let!(:brand) { FactoryBot.create(:brand, domain: 'example.com') }

              before do
                auth_hash.info.email = 'test@example.com'
              end

              it 'adds the user to the brand' do
                expect(from_omniauth.user.brand).to eq(brand)
              end
            end
          end

          context 'when email does not change' do
            before do
              account.update!(email: auth_hash.info.email)
            end

            it 'does not update email' do
              expect { from_omniauth }.not_to change { account.reload.email }.from(auth_hash.info.email)
            end
          end

          context 'when email changes' do
            before do
              auth_hash.info.email = 'hello@world.com'
            end

            it 'updates email ' do
              expect { from_omniauth }.to change { account.reload.email }.to(auth_hash.info.email)
            end
          end

          context 'when token does not change' do
            before do
              account.update!(token: auth_hash.credentials.token)
            end

            it 'does not update token' do
              expect { from_omniauth }.not_to change { account.reload.token }.from(auth_hash.credentials.token)
            end
          end

          context 'when token changes' do
            it 'updates token' do
              expect { from_omniauth }.to change { account.reload.token }.to(auth_hash.credentials.token)
            end
          end

          context 'when secret does not change' do
            before do
              account.update!(secret: auth_hash.credentials.secret)
            end

            it 'does not update secret' do
              expect { from_omniauth }.not_to change { account.reload.secret }.from(auth_hash.credentials.secret)
            end
          end

          context 'when secret changes' do
            before do
              auth_hash.credentials.secret = 'top_secret'
            end

            it 'updates secret' do
              expect { from_omniauth }.to change { account.reload.secret }.to(auth_hash.credentials.secret)
            end
          end
        end
      end
    end
  end
end
