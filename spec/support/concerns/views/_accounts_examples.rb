# frozen_string_literal: true

RSpec.shared_examples '_accounts_partial' do |model_class|
  account_class = model_class.reflect_on_association(:accounts).class_name
  account_class_slug = account_class.underscore.to_sym
  model_class_slug = model_class.to_s.underscore.to_sym
  providers = account_class.constantize.providers.keys

  providers.each do |provider_name|
    context "when provider is #{provider_name}" do
      let(:model) { create(model_class_slug) }

      before do
        without_partial_double_verification do
          allow(view).to receive(model_class_slug).and_return(model)
        end
      end

      context 'when account for provider exists' do
        before do
          create(account_class_slug, model_class_slug => model, provider: provider_name)
        end

        it "renders remove #{provider_name} account link" do
          expect(render).to have_link("Remove #{provider_human_name(provider_name)}")
        end
      end

      context 'when account for provider does not exist' do
        it "renders the authorize #{provider_name} link" do
          expect(render).to have_link("Authorize #{provider_human_name(provider_name)}")
        end
      end
    end
  end
end
