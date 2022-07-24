# frozen_string_literal: true

RSpec.describe BrandAccount, type: :model do
  describe 'Validations' do
    subject(:account) { create(:brand_account) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider).ignoring_case_sensitivity }
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }
    it { is_expected.to validate_presence_of(:screen_name).allow_nil }
  end

  it { is_expected.to define_enum_for(:provider).with_values(twitter: 0, disqus: 1, developer: 99) }

  describe 'Relations' do
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to have_many(:tickets) }
  end

  describe '.from_omniauth' do
    described_class.providers.except(:developer).each_key do |provider|
      context "when provider is #{provider}" do
        subject(:from_omniauth) { described_class.from_omniauth(auth_hash, current_brand) }

        let(:auth_hash) do
          fixture_name = case provider
                         when 'twitter'
                           'twitter_oauth_hash.json'
                         when 'disqus'
                           'disqus_oauth_hash.json'
                         end

          response_content = JSON.parse(file_fixture(fixture_name).read)
          Hashie::Mash.new(response_content)
        end

        context 'when there is no matching account' do
          context 'when creating a new brand' do
            let(:current_brand) { nil }

            it 'returns a new account' do
              expect(from_omniauth).to be_an_instance_of(described_class)
            end

            it 'builds an account entity with correct information' do
              expect(from_omniauth).to have_attributes(
                external_uid: auth_hash.uid, provider:,
                token: auth_hash.credentials.token, secret: auth_hash.credentials.secret,
                email: auth_hash.info.email
              )
            end

            it 'persists the new account' do
              expect(from_omniauth).to be_persisted
            end

            it 'creates a new brand' do
              expect { from_omniauth }.to change(Brand, :count).from(0).to(1)
            end
          end

          context 'when adding the account to existing brand' do
            let!(:current_brand) { create(:brand) }

            before do
              create(:brand_account, provider:, brand: current_brand)
            end

            it 'returns a new account' do
              expect(from_omniauth).to be_an_instance_of(described_class)
            end

            it 'builds an account entity with correct information' do
              expect(from_omniauth).to have_attributes(
                external_uid: auth_hash.uid, provider:,
                token: auth_hash.credentials.token, secret: auth_hash.credentials.secret,
                email: auth_hash.info.email
              )
            end

            it 'persists the new account' do
              expect(from_omniauth).to be_persisted
            end

            it 'does not create new brands' do
              expect { from_omniauth }.not_to change(Brand, :count).from(1)
            end

            it 'adds the account to the specified brand' do
              expect(current_brand.accounts).to include(from_omniauth)
            end
          end
        end

        context 'when there is a matching account' do
          let!(:account) { create(:brand_account, external_uid: auth_hash.uid, provider: auth_hash.provider) }
          let(:current_brand) { account.brand }

          context 'when account belongs to current brand' do
            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'does not change the account owner' do
              expect { from_omniauth }.not_to change { account.reload.brand }.from(account.brand)
            end
          end

          context 'when switching account from different brand' do
            let!(:current_brand) { create(:brand) }

            it 'returns the matching account' do
              expect(from_omniauth).to eq(account)
            end

            it 'does not create new account entities' do
              expect { from_omniauth }.not_to change(described_class, :count).from(1)
            end

            it 'removes the account from existing brand' do
              previous_brand = account.brand

              expect { from_omniauth }.to change {
                                            previous_brand.reload.accounts.find_by(provider:)
                                          }.from(account).to(nil)
            end

            it 'associates the account to current brand' do
              expect(from_omniauth.brand).to eq(current_brand)
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

            it 'updates email' do
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

  describe '#new_mentions' do
    subject(:new_mentions) { account.new_mentions }

    let(:account) { build(:brand_account) }
    let(:client_spy) { instance_spy(Clients::Client) }

    described_class.providers.except(:developer).each_key do |provider|
      context "when provider is #{provider}" do
        before do
          allow(account).to receive(:"#{provider}_client").and_return(client_spy)
          account.provider = provider
        end

        context 'when brand has tickets' do
          before do
            create(:internal_ticket, provider:, brand: account.brand)
          end

          it 'calls client new mentions with last ticket identifier' do
            new_mentions

            expect(client_spy).to have_received(:new_mentions).with(anything)
          end
        end

        context 'when brand does not have tickets' do
          it 'calls client new mentions with nil' do
            new_mentions

            expect(client_spy).to have_received(:new_mentions).with(nil)
          end
        end
      end
    end
  end

  describe '#client' do
    subject(:client) { account.client }

    let(:account) { build(:brand_account) }

    %w[twitter disqus].each do |provider|
      context "when provider is #{provider}" do
        before do
          account.provider = provider
        end

        it { is_expected.to be_kind_of(Clients::Client) }
      end
    end
  end
end
