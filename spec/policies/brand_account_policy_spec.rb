# frozen_string_literal: true

RSpec.describe BrandAccountPolicy, type: :policy do
  subject(:brand_account_policy) { described_class }

  let(:brand_account) { FactoryBot.create(:brand_account) }

  permissions :destroy? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, brand_account, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access to users outside of brand' do
      expect(brand_account_policy).not_to permit(FactoryBot.create(:user), brand_account)
    end

    it 'allows access to users in brand' do
      expect(brand_account_policy).to permit(FactoryBot.create(:user, brand: brand_account.brand), brand_account)
    end
  end
end
