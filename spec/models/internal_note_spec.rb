# frozen_string_literal: true

RSpec.describe InternalNote do
  describe 'Validations' do
    subject(:internal_note) { create(:internal_note) }

    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:creator) }
    it { is_expected.to belong_to(:ticket) }
  end
end
