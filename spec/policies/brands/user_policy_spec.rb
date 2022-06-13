# frozen_string_literal: true

RSpec.describe Brands::UserPolicy, type: :policy do
  subject(:user_policy) { described_class }

  let(:brand) { create(:brand) }
  let(:user) { create(:user, brand:) }

  permissions :create? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, [:brands, user], :create?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access if external user already has brand' do
      expect(user_policy).not_to permit(create(:user), user)
    end

    it 'allows access if external user does not have brand' do
      user.update!(brand: nil)

      expect(user_policy).to permit(create(:user, brand: user.brand), user)
    end
  end

  permissions :destroy? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, [:brands, user], :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access to users outside of brand' do
      expect(user_policy).not_to permit(create(:user), user)
    end

    it 'allows access to users in brand' do
      expect(user_policy).to permit(create(:user, brand: user.brand), user)
    end
  end
end
