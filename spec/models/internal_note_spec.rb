# frozen_string_literal: true

RSpec.describe InternalNote, type: :model do
  describe 'Validations' do
    subject(:internal_note) { FactoryBot.create(:internal_note) }

    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:ticket) }
  end
end
