# frozen_string_literal: true

require './spec/support/concerns/models/has_accounts_examples.rb'

RSpec.describe Brand, type: :model do
  describe 'Validations' do
    subject(:brand) { FactoryBot.create(:brand) }

    it { is_expected.to validate_presence_of(:screen_name) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }

    BrandAccount.providers.keys.each do |provider|
      it { is_expected.to have_one(:"#{provider}_account") }
    end
  end

  it_behaves_like 'has_accounts'

  describe '.search' do
    subject(:search) { described_class.search('hello_world') }

    let!(:hit) { FactoryBot.create(:brand, screen_name: 'hello_world') }
    let!(:miss) { FactoryBot.create(:brand) }

    it 'includes search hits' do
      expect(search).to include(hit)
    end

    it 'does not include misses' do
      expect(search).not_to include(miss)
    end
  end
end
