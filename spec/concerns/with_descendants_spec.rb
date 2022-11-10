# frozen_string_literal: true

RSpec.shared_examples_for 'with_descendants' do
  describe '.with_descendants_hash' do
    subject(:with_descendants_hash) { described_class.root.with_descendants_hash }

    it 'maintains the ticket structure' do
      expect(with_descendants_hash).to eq(
        root_model => { child_model => {} },
        second_root_model => { second_child_model => {} }
      )
    end
  end

  describe '#with_descendants_hash' do
    subject(:with_descendants_hash) { root_model.with_descendants_hash }

    it 'maintains the ticket structure' do
      expect(with_descendants_hash).to eq(
        root_model => { child_model => {} }
      )
    end
  end
end
