# frozen_string_literal: true

require './spec/support/concerns/models/has_accounts_examples.rb'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:brand).optional }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
    it { is_expected.to have_many(:personal_access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:restrict_with_error) }

    UserAccount.providers.keys.each do |provider|
      it { is_expected.to have_one(:"#{provider}_account") }
    end
  end

  it_behaves_like 'has_accounts'
end
