# frozen_string_literal: true

require './spec/support/has_accounts_examples'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:brand).optional }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
    it { is_expected.to have_many(:personal_access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:internal_notes).dependent(:restrict_with_error) }
  end

  it_behaves_like 'has_accounts'
end
