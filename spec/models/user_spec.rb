# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:brand).optional }
    it { is_expected.to have_many(:accounts) }
    it { is_expected.to have_one(:twitter_account) }
    it { is_expected.to have_one(:google_oauth2_account) }
  end

  describe '.not_in_brand' do
    subject(:not_in_brand) { described_class.not_in_brand(brand.id) }

    let(:brand) { FactoryBot.create(:brand) }
    let!(:user_outside_brand) { FactoryBot.create(:user) }

    before do
      brand.users << FactoryBot.create(:user)
    end

    it 'returns just the user outside brand' do
      expect(not_in_brand).to contain_exactly(user_outside_brand)
    end
  end
end
