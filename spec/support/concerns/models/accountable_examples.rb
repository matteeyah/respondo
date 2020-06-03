# frozen_string_literal: true

RSpec.shared_examples 'accountable' do
  describe 'Validations' do
    subject(:account) { FactoryBot.create(described_class.to_s.underscore) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }
  end

  describe '#client' do
    subject(:client) { account.client }

    let(:account) { FactoryBot.build(described_class.to_s.underscore) }

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
