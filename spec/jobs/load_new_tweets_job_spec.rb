# frozen_string_literal: true

RSpec.describe LoadNewTweetsJob, type: :job do
  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    let(:mentions) { [instance_double(Twitter::Tweet), instance_double(Twitter::Tweet)] }
    let(:brand) { instance_double(Brand, id: 123, new_mentions: mentions) }
    let(:ticket_class) { class_spy(Ticket) }

    before do
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
      stub_const('Ticket', ticket_class)
    end

    it 'creates tickets' do
      perform_now

      mentions.each { |mention| expect(ticket_class).to have_received(:create_from_tweet).with(mention, brand).once }
    end
  end
end
