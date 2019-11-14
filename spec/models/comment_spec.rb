# frozen_string_literal: true

RSpec.describe Comment, type: :model do
  describe 'Validations' do
    subject(:comment) { FactoryBot.create(:comment) }

    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:ticket) }
  end
end
