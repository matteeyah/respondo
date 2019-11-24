# frozen_string_literal: true

RSpec.shared_examples 'account' do
  describe 'Validations' do
    subject(:account) { FactoryBot.create(described_class.to_s.underscore) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }
  end

  describe '#client' do
    subject(:client) { account.client }

    let(:account) { FactoryBot.build(described_class.to_s.underscore) }

    context 'when provider is twitter' do
      before do
        account.provider = 'twitter'
      end

      it { is_expected.to be_an_instance_of(Clients::Twitter) }
    end
  end
end
