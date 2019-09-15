# frozen_string_literal: true

RSpec.describe LoadNewTweetsJob, type: :job do
  let(:brand) { FactoryBot.create(:brand) }
  let(:mentions) { [instance_double(Twitter::Tweet), instance_double(Twitter::Tweet)] }
  let(:ticket_class) { class_spy(Ticket) }

  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    before do
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
      allow(brand).to receive(:new_mentions).and_return(mentions)
      stub_const('Ticket', ticket_class)
    end

    it 'creates tickets' do
      perform_now

      expect(ticket_class).to have_received(:from_tweet).with(anything, brand).twice
    end
  end
end
