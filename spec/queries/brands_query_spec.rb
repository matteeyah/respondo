# frozen_string_literal: true

RSpec.describe BrandsQuery, type: :query do
  let(:query) { described_class.new(Brand.all, params) }

  describe '#call' do
    subject(:call) { query.call }

    let(:params) { { query: 'hello_world' } }
    let!(:hit) { create(:brand, screen_name: 'hello_world') }
    let!(:miss) { create(:brand) }

    it 'includes search hits' do
      expect(call).to include(hit)
    end

    it 'does not include misses' do
      expect(call).not_to include(miss)
    end
  end
end
