# frozen_string_literal: true

RSpec.describe Clients::ProviderClient do
  let(:klass) { Class.new(described_class) }
  let(:klass_instance) { klass.new }

  describe '#new_mentions' do
    subject(:new_mentions) { klass_instance.new_mentions(nil) }

    it 'raises an error' do
      expect { new_mentions }.to raise_error(NotImplementedError)
    end
  end

  describe '#reply' do
    subject(:reply) { klass_instance.reply('does not matter', '12321') }

    it 'raises an error' do
      expect { reply }.to raise_error(NotImplementedError)
    end
  end
end
