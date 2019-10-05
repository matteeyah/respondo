# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe Brands::TicketsController, type: :request do
  include SignInOutHelpers

  let(:brand) { FactoryBot.create(:brand) }

  describe 'GET index' do
    subject(:get_index) { get "/brands/#{brand.id}/tickets" }

    before do
      FactoryBot.create(:ticket, status: :open, brand: brand)
      FactoryBot.create(:ticket, status: :solved, brand: brand)
    end

    it 'sets open tickets' do
      get_index

      expect(assigns(:open_tickets)).to eq(brand.tickets.root.open)
    end

    it 'sets solved tickets' do
      get_index

      expect(assigns(:solved_tickets)).to eq(brand.tickets.root.solved)
    end

    it 'renders the index template' do
      expect(get_index).to render_template('brands/tickets/index', partial: 'twitter/_feed')
    end
  end

  describe 'POST reply' do
    subject(:post_reply) { post "/brands/#{brand.id}/tickets/#{ticket.id}/reply", params: { response_text: 'does not matter' } }

    let(:ticket) { FactoryBot.create(:ticket, brand: brand) }

    context 'when authorized' do
      let(:user) { FactoryBot.create(:user, :with_account) }

      let(:tweet) do
        instance_double(Twitter::Tweet, id: '1', text: 'does not matter', in_reply_to_tweet_id: ticket.external_uid,
                                        user: instance_double(Twitter::User, id: '2', screen_name: 'test'))
      end

      let(:client) { instance_spy(Clients::Twitter, reply: tweet) }
      let(:client_class) { class_spy(Clients::Twitter, new: client) }

      before do
        sign_in(user)
      end

      context 'when authorized as a brand' do
        before do
          brand.users << user

          stub_const('Clients::Twitter', client_class)
        end

        it 'replies to the ticket' do
          post_reply

          expect(client).to have_received(:reply).with('does not matter', ticket.external_uid)
        end

        it 'creates a reply ticket' do
          expect { post_reply }.to change(Ticket, :count).from(1).to(2)
        end

        it 'creates a reply ticket with matching attributes' do
          post_reply

          expect(Ticket.find_by(external_uid: tweet.id)).to have_attributes(parent: ticket, content: 'does not matter')
        end
      end

      context 'when authorized as a user' do
        before do
          FactoryBot.create(:account, provider: 'twitter', user: user)

          stub_const('Clients::Twitter', client_class)
        end

        it 'replies to the ticket' do
          post_reply

          expect(client).to have_received(:reply).with('does not matter', ticket.external_uid)
        end

        it 'creates a reply ticket' do
          expect { post_reply }.to change(Ticket, :count).from(1).to(2)
        end

        it 'creates a reply ticket with matching attributes' do
          post_reply

          expect(Ticket.find_by(external_uid: tweet.id)).to have_attributes(parent: ticket, content: 'does not matter')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        post_reply

        expect(controller.flash[:alert]).to eq('You are not allowed to reply to the ticket.')
      end

      it 'redirects the user' do
        expect(post_reply).to redirect_to(root_path)
      end
    end
  end

  describe 'POST invert_status' do
    subject(:post_invert_status) { post "/brands/#{brand.id}/tickets/#{ticket.id}/invert_status" }

    let(:ticket) { FactoryBot.create(:ticket) }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user, :with_account) }

      before do
        brand.users << user

        sign_in(user)
      end

      context 'when the ticket is open' do
        before do
          ticket.update(status: 'open')
        end

        it 'solves the ticket' do
          expect { post_invert_status }.to change { ticket.reload.status }.from('open').to('solved')
        end
      end

      context 'when the ticket is solved' do
        before do
          ticket.update(status: 'solved')
        end

        it 'opens the ticket' do
          expect { post_invert_status }.to change { ticket.reload.status }.from('solved').to('open')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        post_invert_status

        expect(controller.flash[:alert]).to eq('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(post_invert_status).to redirect_to(root_path)
      end
    end
  end

  describe 'POST refresh' do
    subject(:post_refresh) { post "/brands/#{brand.id}/tickets/refresh" }

    let(:load_new_tweets_job_class) { class_spy(LoadNewTweetsJob) }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user, :with_account) }

      before do
        brand.users << user

        sign_in(user)

        stub_const('LoadNewTweetsJob', load_new_tweets_job_class)
      end

      it 'calls the background worker' do
        post_refresh

        expect(load_new_tweets_job_class).to have_received(:perform_now)
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        post_refresh

        expect(controller.flash[:alert]).to eq('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(post_refresh).to redirect_to(root_path)
      end
    end
  end
end
