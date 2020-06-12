# frozen_string_literal: true

RSpec.describe UserAccountPolicy, type: :policy do
  subject(:user_account_policy) { described_class }

  let(:user_account) { FactoryBot.create(:user_account) }

  permissions :destroy? do
    it 'denies access to guests' do
      expect(user_account_policy).not_to permit(nil, user_account)
    end

    it 'denies access to other users' do
      expect(user_account_policy).not_to permit(FactoryBot.create(:user), user_account)
    end

    it 'allows access to themselves' do
      expect(user_account_policy).to permit(user_account.user, user_account)
    end
  end
end
