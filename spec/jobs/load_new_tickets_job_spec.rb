# frozen_string_literal: true

RSpec.describe LoadNewTicketsJob, type: :job do
  describe '#perform' do
    subject(:perform_now) { described_class.perform_now(brand.id) }

    let(:brand) { create(:brand) }
    let(:twitter_account) { create(:brand_account, provider: 'twitter', brand:) }
    let(:disqus_account) { create(:brand_account, provider: 'disqus', brand:) }
    let!(:parent) { create(:internal_ticket, status: :solved, brand:).base_ticket }

    let(:twitter_mentions) do
      [instance_double(
        Twitter::Tweet,
        JSON.parse(file_fixture('twitter_post_hash.json').read).merge(
          in_reply_to_tweet_id: parent.external_uid,
          user: instance_double(Twitter::User, id: '2', screen_name: 'test')
        ).deep_symbolize_keys
      )]
    end
    let(:disqus_mentions) do
      [JSON.parse(file_fixture('disqus_post_hash.json').read).deep_symbolize_keys]
    end

    before do
      allow(twitter_account).to receive(:new_mentions).and_return(twitter_mentions)
      allow(disqus_account).to receive(:new_mentions).and_return(disqus_mentions)
      allow(brand).to receive(:accounts).and_return([twitter_account, disqus_account])
      allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
    end

    it 'creates ticket' do
      expect { perform_now }.to change(Ticket, :count).from(1).to(3)
    end
  end
end
