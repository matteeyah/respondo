# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'

RSpec.describe Brands::Tickets::RepliesController do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }
  let!(:ticket) { create(:internal_ticket, brand:).base_ticket }
  let(:client) { instance_spy(Clients::Client) }

  before do
    stub_const(Clients::Twitter.to_s, class_spy(Clients::Twitter, new: client))
    stub_const(Clients::Disqus.to_s, class_spy(Clients::Disqus, new: client))
    stub_const(Clients::External.to_s, class_spy(Clients::External, new: client))
  end

  shared_examples 'valid reply' do
    it 'replies to the ticket' do
      post_create

      expect(client).to have_received(:reply).with('does not matter', ticket.external_uid)
    end

    it 'creates a reply ticket' do
      expect { post_create }.to change(Ticket, :count).from(1).to(2)
    end

    it 'creates a reply ticket with matching attributes' do
      post_create

      expect(ticket.replies.first).to have_attributes(parent: ticket, content: instance_of(String))
    end

    it 'redirects to the ticket' do
      post_create

      expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
    end
  end

  shared_examples 'invalid reply' do
    it 'does not create a reply ticket' do
      expect { post_create }.not_to change(Ticket, :count).from(1)
    end

    it 'redirects to the ticket' do
      post_create

      expect(response.body).to redirect_to(brand_ticket_path(ticket.brand, ticket))
    end
  end

  describe 'POST create' do
    subject(:post_create) do
      post "/brands/#{brand.id}/tickets/#{ticket.id}/replies", params: { ticket: { content: 'does not matter' } }
    end

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when ticket is internal' do
        BrandAccount.providers.except(:developer).each_key do |provider|
          context "when ticket provider is #{provider}" do
            let(:ticket) do
              create(
                :internal_ticket,
                source: create(:brand_account, provider:, brand:),
                brand:
              ).base_ticket
            end

            let(:client_error) { Twitter::Error::Forbidden.new('error') }
            let(:client_response) do
              case provider
              when 'twitter'
                instance_double(
                  Twitter::Tweet,
                  JSON.parse(file_fixture('twitter_post_hash.json').read).merge(
                    in_reply_to_tweet_id: ticket.external_uid,
                    user: instance_double(Twitter::User, id: '2', screen_name: 'test')
                  ).deep_symbolize_keys
                )
              when 'disqus'
                JSON.parse(file_fixture('disqus_post_hash.json').read)
                  .merge(parent: ticket.external_uid).deep_symbolize_keys
              end
            end

            context 'when user is authorized' do
              before do
                create(:brand_account, provider:, brand:)

                brand.users << user
              end

              context 'when brand has subscription' do
                before do
                  create(:subscription, brand:)
                end

                context 'when reply is valid' do
                  before do
                    allow(client).to receive(:reply).and_return(client_response)
                  end

                  it_behaves_like 'valid reply'
                end

                context 'when reply is invalid' do
                  before do
                    allow(client).to receive(:reply).and_raise(client_error)
                  end

                  it_behaves_like 'invalid reply'
                end
              end

              context 'when brand does not have subscription' do
                it 'redirects the user back (to root)' do
                  expect(post_create).to redirect_to(root_path)
                end
              end
            end

            context 'when user is not authorized' do
              it 'redirects the user back (to root)' do
                expect(post_create).to redirect_to(root_path)
              end
            end
          end
        end
      end

      context 'when ticket is external' do
        let(:ticket) { create(:external_ticket, brand:).base_ticket }

        let(:client_error) { Twitter::Error::Forbidden.new('error') }
        let(:client_response) do
          JSON.parse(file_fixture('external_post_hash.json').read)
            .merge(parent_uid: ticket.external_uid).deep_symbolize_keys
        end

        context 'when user is authorized' do
          before do
            brand.users << user
          end

          context 'when brand has subscription' do
            before do
              create(:subscription, brand:)
            end

            context 'when reply is valid' do
              before do
                allow(client).to receive(:reply).and_return(client_response)
              end

              it_behaves_like 'valid reply'
            end

            context 'when reply is invalid' do
              before do
                allow(client).to receive(:reply).and_raise(client_error)
              end

              it_behaves_like 'invalid reply'
            end
          end

          context 'when brand does not have subscription' do
            it 'redirects the user back (to root)' do
              expect(post_create).to redirect_to(root_path)
            end
          end
        end

        context 'when user is not authorized' do
          it 'redirects the user back (to root)' do
            expect(post_create).to redirect_to(root_path)
          end
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects the user back (to root)' do
        expect(post_create).to redirect_to(root_path)
      end
    end
  end
end
