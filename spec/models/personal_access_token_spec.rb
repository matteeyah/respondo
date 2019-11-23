# frozen_string_literal: true

RSpec.describe PersonalAccessToken, type: :model do
  describe 'Validations' do
    subject(:personal_access_token) { FactoryBot.create(:personal_access_token) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
  end
end
