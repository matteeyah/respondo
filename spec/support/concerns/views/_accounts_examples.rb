# frozen_string_literal: true

RSpec.shared_examples '_accounts_partial' do |model_class|
  account_class = model_class.reflect_on_association(:accounts).class_name
  account_class_slug = account_class.underscore.to_sym
  model_class_slug = model_class.to_s.underscore.to_sym
  providers = account_class.constantize.providers.keys

  providers.each do |provider_name|
    context "when provider is #{provider_name}" do
      let(:provider) { provider_name }

      context 'when account for provider exists' do
        before do
          FactoryBot.create(account_class_slug, model_class_slug => model_class.first, provider: provider)
        end

        it "renders remove #{provider_name} account link" do
          expect(render).to have_link("Remove #{provider_human_name(provider)}")
        end
      end

      context 'when account for provider does not exist' do
        it "renders the authorize #{provider_name} link" do
          expect(render).to have_link("Authorize #{provider_human_name(provider)}")
        end
      end
    end
  end
end
