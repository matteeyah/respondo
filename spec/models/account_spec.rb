# frozen_string_literal: true

RSpec.describe Account, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }

    it do
      FactoryBot.create(:account)
      is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider)
    end
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[twitter google_oauth2]) }

  describe '.from_omniauth' do
    %w[twitter google_oauth2].each do |provider|
      context "when provider is #{provider}" do
        let(:auth_hash) do
          fixture_name = case provider
                         when 'twitter'
                           'twitter_oauth_hash.json'
                         when 'google_oauth2'
                           'google_oauth_hash.json'
                         end
          JSON.parse(file_fixture(fixture_name).read, object_class: OpenStruct)
        end

        subject(:from_omniauth) { Account.from_omniauth(auth_hash) }

        context 'when there is no matching account' do
          it 'creates an account' do
            expect { from_omniauth }.to change { Account.count }.from(0).to(1)
          end

          it 'creates an account entity with correct info' do
            expect(from_omniauth).to have_attributes(external_uid: auth_hash.uid)
          end

          it 'creates a user' do
            expect { from_omniauth }.to change { User.count }.from(0).to(1)
          end
        end

        context 'when there is a matching account' do
          let!(:account) { FactoryBot.create(:account, external_uid: auth_hash.uid, provider: auth_hash.provider) }

          it 'returns the matching account' do
            expect(from_omniauth).to eq(account)
          end

          context 'when the auth has more info' do
            let(:email) { Faker::Internet.safe_email }

            before do
              auth_hash.info.email = email
            end

            it 'updates the record with extra information' do
              expect { from_omniauth }.to change { account.reload.email }.from(nil).to(email)
            end
          end
        end
      end
    end
  end

  describe '#client' do
    let(:account) { FactoryBot.build(:account) }

    subject(:client) { account.client }

    context 'when provider is twitter' do
      before do
        account.provider = 'twitter'
      end

      it { is_expected.to be_an_instance_of(Twitter::REST::Client) }
    end

    context 'when provider is not supported' do
      before do
        account.provider = 'google_oauth2'
      end

      it { is_expected.to eq(nil) }
    end
  end
end
