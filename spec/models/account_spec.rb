# frozen_string_literal: true

RSpec.describe Account, type: :model do
  describe 'Validations' do
    subject(:account) { FactoryBot.create(:account) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:provider) }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[twitter google_oauth2]) }

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.from_omniauth' do
    %w[twitter google_oauth2].each do |provider|
      context "when provider is #{provider}" do
        subject(:from_omniauth) { described_class.from_omniauth(auth_hash, user) }

        let(:auth_hash) do
          fixture_name = case provider
                         when 'twitter'
                           'twitter_oauth_hash.json'
                         when 'google_oauth2'
                           'google_oauth_hash.json'
                         end

          JSON.parse(file_fixture(fixture_name).read, object_class: OpenStruct)
        end

        context 'when user is not specified' do
          let(:user) { nil }

          context 'when there is not a matching account' do
            it 'creates a new account' do
              expect { from_omniauth }.to change(described_class, :count).from(0).to(1)
            end

            it 'returns a new account' do
              expect(from_omniauth).to be_an_instance_of(described_class)
            end

            it 'builds an account entity with correct information' do
              expect(from_omniauth).to have_attributes(external_uid: auth_hash.uid, provider: provider, token: auth_hash.credentials.token, secret: auth_hash.credentials.secret, email: auth_hash.info.email)
            end

            it 'creates a user' do
              expect { from_omniauth }.to change(User, :count).from(0).to(1)
            end

            it 'creates a user entity with correct information' do
              expect(from_omniauth.user).to have_attributes(name: auth_hash.info.name)
            end

            it 'persists the new account' do
              expect(from_omniauth).to be_persisted
            end
          end

          context 'when there is a matching account' do
            let!(:account) { FactoryBot.create(:account, external_uid: auth_hash.uid, provider: auth_hash.provider) }

            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'creates a user' do
              expect { from_omniauth }.to change(User, :count).from(1).to(2)
            end

            it 'creates a user entity with correct information' do
              expect(from_omniauth.user).to have_attributes(name: auth_hash.info.name)
            end
          end
        end

        context 'when the user is specified' do
          let!(:user) { FactoryBot.create(:user) }

          context 'when there is not a matching account' do
            it 'creates a new account' do
              expect { from_omniauth }.to change(described_class, :count).from(0).to(1)
            end

            it 'returns a new account' do
              expect(from_omniauth).to be_an_instance_of(described_class)
            end

            it 'builds an account entity with correct information' do
              expect(from_omniauth).to have_attributes(external_uid: auth_hash.uid, provider: provider, token: auth_hash.credentials.token, secret: auth_hash.credentials.secret, email: auth_hash.info.email)
            end

            it 'creates a user' do
              expect { from_omniauth }.to change(User, :count).from(0).to(1)
            end

            it 'creates a user entity with correct information' do
              expect(from_omniauth.user).to have_attributes(name: auth_hash.info.name)
            end

            it 'persists the new account' do
              expect(from_omniauth).to be_persisted
            end
          end

          context 'when there is a matching account' do
            let!(:account) { FactoryBot.create(:account, external_uid: auth_hash.uid, provider: auth_hash.provider) }

            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'does not create a user' do
              expect { from_omniauth }.not_to change(User, :count).from(2)
            end

            it 'creates a user entity with correct information' do
              expect(from_omniauth.user).to have_attributes(name: auth_hash.info.name)
            end
          end
        end
      end
    end
  end

  describe '#client' do
    subject(:client) { account.client }

    let(:account) { FactoryBot.build(:account) }

    context 'when provider is twitter' do
      before do
        account.provider = 'twitter'
      end

      it { is_expected.to be_an_instance_of(Clients::Twitter) }
    end

    context 'when provider is not supported' do
      before do
        account.provider = 'google_oauth2'
      end

      it { is_expected.to eq(nil) }
    end
  end
end
