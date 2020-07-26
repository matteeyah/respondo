# frozen_string_literal: true

RSpec.describe BrandPolicy, type: :policy do
  subject(:brand_policy) { described_class }

  let(:brand) { FactoryBot.create(:brand) }

  permissions :edit?, :update? do
    it 'denies access to guests' do
      expect(brand_policy).not_to permit(nil, brand)
    end

    it 'denies access to users outside brand' do
      expect(brand_policy).not_to permit(FactoryBot.create(:user), brand)
    end

    it 'allows access to users in brand' do
      expect(brand_policy).to permit(FactoryBot.create(:user, brand: brand), brand)
    end
  end

  permissions :subscription? do
    it 'allows if subscription checks are skipped' do
      allow(Flipper).to receive(:enabled?).with(:disable_subscriptions).and_return(true)

      expect(brand_policy).to permit(nil, brand)
    end

    it 'allows if brand has subscription' do
      FactoryBot.create(:subscription, brand: brand)

      expect(brand_policy).to permit(nil, brand)
    end

    it 'denies if brand does not have subscription' do
      expect(brand_policy).not_to permit(nil, brand)
    end
  end
end
