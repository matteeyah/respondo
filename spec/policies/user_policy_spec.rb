# frozen_string_literal: true

RSpec.describe UserPolicy, type: :policy do
  subject(:user_policy) { described_class }

  let(:user) { FactoryBot.create(:user) }

  permissions :edit? do
    it 'denies access to guests' do
      expect(user_policy).not_to permit(nil, user)
    end

    it 'denies access to other users' do
      expect(user_policy).not_to permit(FactoryBot.create(:user), user)
    end

    it 'allows access to self' do
      expect(user_policy).to permit(user, user)
    end
  end
end
