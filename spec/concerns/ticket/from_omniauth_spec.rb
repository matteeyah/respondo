# frozen_string_literal: true

RSpec.shared_examples_for 'from_omniauth' do
  shared_examples 'from method' do
    context 'when user is not specified' do
      let(:user) { nil }

      it 'creates a new ticket' do
        expect { subject }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(subject).to be_instance_of(described_class)
      end

      it 'persists the new ticket' do
        expect(subject).to be_persisted
      end

      it 'builds a ticket with correct information' do
        expect(subject).to have_attributes(expected_attributes.merge(parent: nil))
      end

      context 'when parent exists' do
        before do
          # The parent is lazily evaluated, this forced the record to get created.
          parent
        end

        it 'assigns the parent to the ticket' do
          expect(subject).to have_attributes(parent:)
        end
      end
    end

    context 'when the user is specified' do
      let(:user) { create(:user) }

      it 'creates a new ticket' do
        expect { subject }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(subject).to be_instance_of(described_class)
      end

      it 'persists the new ticket' do
        expect(subject).to be_persisted
      end

      it 'builds a ticket with correct information' do
        expect(subject).to have_attributes(expected_attributes.merge(parent: nil))
      end

      context 'when parent exists' do
        before do
          # The parent is lazily evaluated, this forced the record to get created.
          parent
        end

        it 'assigns the parent to the ticket' do
          expect(subject).to have_attributes(parent:)
        end
      end
    end
  end

  describe '.from_client_response!' do
    subject(:from_client_response!) { described_class.from_client_response!(provider, ticket_body, source, user) }

    context 'when ticket is internal' do
      BrandAccount.providers.except(:developer).each_key do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }
          let(:source) { create(:brand_account, provider:) }
          let!(:parent) { create(:internal_ticket, source:, brand: source.brand).base_ticket }
          let(:user) { parent.creator }

          let(:ticket_body) do
            case provider
            when 'twitter'
              instance_double(
                Twitter::Tweet,
                JSON.parse(file_fixture('twitter_post_hash.json').read).merge(
                  in_reply_to_tweet_id: parent.external_uid,
                  user: instance_double(Twitter::User, id: '2', screen_name: 'test')
                ).deep_symbolize_keys
              )
            when 'disqus'
              JSON.parse(file_fixture('disqus_post_hash.json').read)
                .merge(parent: parent.external_uid).deep_symbolize_keys
            end
          end

          it 'creates ticket' do
            expect { from_client_response! }.to change(described_class, :count).from(1).to(2)
          end
        end
      end
    end

    context 'when ticket is external' do
      let!(:parent) { create(:external_ticket).base_ticket }
      let(:provider) { 'external' }
      let(:source) { parent.brand }
      let(:user) { parent.creator }

      let(:ticket_body) do
        JSON.parse(file_fixture('external_post_hash.json').read)
          .merge(parent_uid: parent.external_uid).deep_symbolize_keys
      end

      it 'creates ticket' do
        expect { from_client_response! }.to change(described_class, :count).from(1).to(2)
      end
    end
  end

  describe '.from_tweet!' do
    subject(:from_tweet!) { described_class.from_tweet!(tweet, account, user) }

    let(:account) { create(:brand_account, provider: 'twitter') }
    let(:author) { create(:author) }

    let(:tweet) do
      instance_double(Twitter::Tweet,
                      JSON.parse(file_fixture('twitter_post_hash.json').read).deep_symbolize_keys)
    end

    before do
      allow(Author).to receive(:from_twitter_user!).with(tweet.user).and_return(author)
    end

    it_behaves_like 'from method' do
      let(:parent) do
        create(
          :internal_ticket, external_uid: tweet.in_reply_to_tweet_id, brand: account.brand, source: account
        ).base_ticket
      end
      let(:expected_attributes) do
        {
          external_uid: tweet.id, provider: 'twitter', content: tweet.attrs[:full_text],
          brand: account.brand, author:, creator: user
        }
      end
    end
  end

  describe '.from_disqus_post!' do
    subject(:from_disqus_post!) { described_class.from_disqus_post!(disqus_post, account, user) }

    let(:account) { create(:brand_account, provider: 'disqus') }
    let(:author) { create(:author) }

    let(:disqus_post) { JSON.parse(file_fixture('disqus_post_hash.json').read).deep_symbolize_keys }

    before do
      allow(Author).to receive(:from_disqus_user!).with(disqus_post[:author]).and_return(author)
    end

    it_behaves_like 'from method' do
      let(:parent) do
        create(
          :internal_ticket, external_uid: disqus_post[:parent], brand: account.brand, source: account
        ).base_ticket
      end
      let(:expected_attributes) do
        {
          external_uid: disqus_post[:id], provider: 'disqus', content: disqus_post[:raw_message],
          brand: account.brand, author:, creator: user
        }
      end
    end
  end

  describe '.from_external_ticket!' do
    subject(:from_external_ticket!) { described_class.from_external_ticket!(external_ticket_json, brand, user) }

    let(:brand) { create(:brand) }
    let(:author) { create(:author) }
    let(:user) { nil }

    let(:external_ticket_json) { JSON.parse(file_fixture('external_post_hash.json').read).deep_symbolize_keys }

    before do
      allow(Author).to receive(:from_external_author!).with(external_ticket_json[:author]).and_return(author)
    end

    it_behaves_like 'from method' do
      let(:parent) do
        create(
          :external_ticket, external_uid: external_ticket_json[:parent_uid], brand:
        ).base_ticket
      end
      let(:expected_attributes) do
        {
          external_uid: external_ticket_json[:external_uid], provider: 'external',
          content: external_ticket_json[:content],
          brand:, author:, creator: user
        }
      end
    end

    it 'sets the response url' do
      expect(from_external_ticket!.external_ticket).to have_attributes(response_url: 'https://response_url.com')
    end
  end
end
