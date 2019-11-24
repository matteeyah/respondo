# frozen_string_literal: true

RSpec.shared_examples 'has_accounts' do
  account_class = described_class.reflect_on_association(:accounts).class_name
  account_class_slug = account_class.underscore.to_sym
  model_class_slug = described_class.to_s.underscore.to_sym
  providers = account_class.constantize.providers.keys

  describe '#account_for_provider?' do
    subject(:account_for_provider?) { model.account_for_provider?(provider) }

    let(:model) { FactoryBot.create(described_class.to_s.underscore) }

    providers.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          before do
            FactoryBot.create(account_class_slug, model_class_slug => model, provider: provider)
          end

          it { is_expected.to eq(true) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to eq(false) }
        end
      end
    end
  end

  describe '#client_for_provider' do
    subject(:client_for_provider) { model.client_for_provider(provider) }

    let(:model) { FactoryBot.create(described_class.to_s.underscore) }

    providers.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          let!(:account) { FactoryBot.create(account_class_slug, model_class_slug => model, provider: provider) }

          it { is_expected.to be_an_instance_of(account.client.class) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to eq(nil) }
        end
      end
    end
  end
end
