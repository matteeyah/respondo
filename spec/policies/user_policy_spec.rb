# frozen_string_literal: true

RSpec.describe UserPolicy, type: :policy do
  subject(:user_policy) { described_class }

  let(:brand) { FactoryBot.create(:brand) }
  let(:user) { FactoryBot.create(:user, brand: brand) }

  permissions :edit? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, user, :edit?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access to other users' do
      expect(user_policy).not_to permit(FactoryBot.create(:user), user)
    end

    it 'allows access to self' do
      expect(user_policy).to permit(user, user)
    end
  end

  permissions :create? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, user, :create?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access if external user already has brand' do
      expect(user_policy).not_to permit(FactoryBot.create(:user), user)
    end

    it 'allows access if external user does not have brand' do
      user.update!(brand: nil)

      expect(user_policy).to permit(FactoryBot.create(:user, brand: user.brand), user)
    end
  end

  permissions :destroy? do
    it 'denies access to guests' do
      expect { Pundit.authorize(nil, user, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'denies access to users outside of brand' do
      expect(user_policy).not_to permit(FactoryBot.create(:user), user)
    end

    it 'allows access to users in brand' do
      expect(user_policy).to permit(FactoryBot.create(:user, brand: user.brand), user)
    end
  end
end
