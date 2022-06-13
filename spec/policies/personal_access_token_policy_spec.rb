# frozen_string_literal: true

RSpec.describe PersonalAccessTokenPolicy, type: :policy do
  subject(:personal_access_token_policy) { described_class }

  let(:personal_access_token) { create(:personal_access_token) }

  permissions :create?, :destroy? do
    it 'denies access to guests' do
      expect(personal_access_token_policy).not_to permit(nil, personal_access_token)
    end

    it 'denies access to other users' do
      expect(personal_access_token_policy).not_to permit(create(:user), personal_access_token)
    end

    it 'allows access to themselves' do
      expect(personal_access_token_policy).to permit(personal_access_token.user, personal_access_token)
    end
  end
end
