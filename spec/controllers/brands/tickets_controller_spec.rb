# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe Brands::TicketsController, type: :controller do
  include SignInOutHelpers

  let(:brand) { FactoryBot.create(:brand) }

  describe 'GET index' do
    subject(:get_index) { get :index, params: { brand_id: brand.id } }

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
    subject(:post_reply) { post :reply, params: { brand_id: brand.id, ticket_id: ticket.id, response_text: 'does not matter' } }

    let(:ticket) { FactoryBot.create(:ticket, brand: brand) }

    context 'when authorized' do
      let(:user) { FactoryBot.create(:user) }

      let(:tweet) do
        instance_double(Twitter::Tweet, id: '1', text: 'does not matter', in_reply_to_tweet_id: ticket.external_uid,
                        user: instance_double(Twitter::User, id: '2', screen_name: 'test'))
      end

      let(:client) do
        instance_spy(Clients::Twitter, reply: tweet)
      end

      before do
        sign_in(user)
      end

      context 'when authorized as a brand' do
        before do
          brand.users << user

          allow(controller).to receive(:brand).and_return(brand)
          allow(brand).to receive(:twitter).and_return(client)
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

          expect(Ticket.last).to have_attributes(parent: ticket, content: 'does not matter')
        end
      end

      context 'when authorized as a user' do
        before do
          allow(controller).to receive(:current_user).and_return(user)
          allow(user).to receive(:client_for_provider).and_return(client)
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

          expect(Ticket.last).to have_attributes(parent: ticket, content: 'does not matter')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        post_reply

        expect(controller).to set_flash[:alert].to('You are not allowed to reply to the ticket.')
      end

      it 'redirects the user' do
        expect(post_reply).to redirect_to(root_path)
      end
    end
  end

  describe 'POST invert_status' do
    subject(:post_invert_status) { post :invert_status, params: { brand_id: brand.id, ticket_id: ticket.id } }

    let(:ticket) { FactoryBot.create(:ticket) }

    before do
      allow(controller).to receive(:brand).and_return(brand)
      allow(controller).to receive(:ticket).and_return(ticket)
    end

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      context 'when the ticket is open' do
        before do
          ticket.status = 'open'
        end

        it 'solves the ticket' do
          expect { post_invert_status }.to change(ticket, :status).from('open').to('solved')
        end
      end

      context 'when the ticket is solved' do
        before do
          ticket.status = 'solved'
        end

        it 'opens the ticket' do
          expect { post_invert_status }.to change(ticket, :status).from('solved').to('open')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        post_invert_status

        expect(controller).to set_flash[:alert].to('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(post_invert_status).to redirect_to(root_path)
      end
    end
  end

  describe 'POST refresh' do
    subject(:post_refresh) { post :refresh, params: { brand_id: brand.id } }

    let(:load_new_tweets_job_class) { class_spy(LoadNewTweetsJob) }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

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

        expect(controller).to set_flash[:alert].to('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(post_refresh).to redirect_to(root_path)
      end
    end
  end
end
