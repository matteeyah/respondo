# frozen_string_literal: true

RSpec.describe LoadNewTweetsJob, type: :job do
  let(:brand) { FactoryBot.create(:brand) }
  let(:mentions) { [double('Mention#1'), double('Mention#2')] }

  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    before do
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
      allow(brand).to receive(:new_mentions).and_return(mentions)
    end

    it 'creates tickets' do
      expect(Ticket).to receive(:from_tweet).with(anything, brand).exactly(2).times

      perform_now
    end
  end
end
