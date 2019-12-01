# frozen_string_literal: true

RSpec.describe LoadNewTicketsJob, type: :job do
  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    let(:brand) { FactoryBot.create(:brand) }
    let(:twitter_account) { FactoryBot.create(:brand_account, provider: 'twitter', brand: brand) }
    let(:disqus_account) { FactoryBot.create(:brand_account, provider: 'disqus', brand: brand) }

    let(:twitter_mentions) do
      [instance_double(
        Twitter::Tweet,
        id: '1234', in_reply_to_tweet_id: parent.external_uid,
        attrs: { full_text: 'hello' },
        user: OpenStruct.new(id: '1234', screen_name: 'example')
      )]
    end
    let(:disqus_mentions) do
      [{
        id: '12321',
        author: { id: '12321', username: 'bestusername' },
        parent: '123454321',
        raw_message: 'hello world'
      }]
    end

    let(:parent) { FactoryBot.create(:ticket, status: :solved, brand: brand) }

    before do
      allow(twitter_account).to receive(:new_mentions).and_return(twitter_mentions)
      allow(disqus_account).to receive(:new_mentions).and_return(disqus_mentions)
      allow(brand).to receive(:accounts).and_return([twitter_account, disqus_account])
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
    end

    it 'creates ticket' do
      expect { perform_now }.to change(Ticket, :count).from(1).to(3)
    end

    it 'opens parent ticket' do
      expect { perform_now }.to change { parent.reload.status }.from('solved').to('open')
    end
  end
end
