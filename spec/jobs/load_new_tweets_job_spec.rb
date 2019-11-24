# frozen_string_literal: true

RSpec.describe LoadNewTweetsJob, type: :job do
  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    let(:brand) { FactoryBot.create(:brand) }
    let(:account) { FactoryBot.create(:brand_account, provider: 'twitter', brand: brand) }
    let(:parent) { FactoryBot.create(:ticket, status: :solved, brand: brand) }

    let(:mentions) do
      [instance_double(
        Twitter::Tweet,
        id: '1234', in_reply_to_tweet_id: parent.external_uid,
        attrs: { full_text: 'hello' },
        user: OpenStruct.new(id: '1234', screen_name: 'example')
      )]
    end

    before do
      allow(brand).to receive(:twitter_account).and_return(account)
      allow(account).to receive(:new_mentions).and_return(mentions)
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
    end

    it 'creates ticket' do
      expect { perform_now }.to change(Ticket, :count).from(1).to(2)
    end

    it 'opens parent ticket' do
      expect { perform_now }.to change { parent.reload.status }.from('solved').to('open')
    end
  end
end
