# frozen_string_literal: true

RSpec.describe TicketCreator, type: :service do
  let(:service) { described_class.new(provider, ticket_body, source, user) }

  describe '#call' do
    subject(:call) { service.call }

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
            expect { call }.to change(Ticket, :count).from(1).to(2)
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
        expect { call }.to change(Ticket, :count).from(1).to(2)
      end
    end
  end
end
