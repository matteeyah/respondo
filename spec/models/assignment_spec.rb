# frozen_string_literal: true

RSpec.describe Assignment, type: :model do
  describe 'Validations' do
    subject(:assignment) { create(:assignment) }

    it { is_expected.to validate_uniqueness_of(:ticket_id) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:ticket) }
  end
end
