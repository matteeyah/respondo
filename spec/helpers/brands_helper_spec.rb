# frozen_string_literal: true

RSpec.describe BrandsHelper, type: :helper do
  describe '#add_users_dropdown_options_for' do
    subject(:add_users_dropdown_options_for) { helper.add_users_dropdown_options_for }

    let(:brand) { FactoryBot.create(:brand) }
    let(:user_in_brand) { FactoryBot.create(:user) }
    let(:user_in_other_brand) { FactoryBot.create(:user) }
    let!(:user_without_brand) { FactoryBot.create(:user) }

    before do
      brand.users << user_in_brand
      FactoryBot.create(:brand).users << user_in_other_brand
    end

    it 'returns just users outside brand' do
      expect(add_users_dropdown_options_for).to contain_exactly([user_without_brand.name, user_without_brand.id])
    end
  end

  describe '#subscription_badge_class' do
    subject(:subscription_badge_class) { helper.subscription_badge_class(subscription_status) }

    [[nil, 'danger'], %w[deleted danger], %w[past_due warning], %w[trialing success], %w[active success]].each do |status_pair|
      context "when subscription is #{status_pair.first}" do
        let(:subscription_status) { status_pair.first }

        it { is_expected.to eq(status_pair.second) }
      end
    end
  end
end
