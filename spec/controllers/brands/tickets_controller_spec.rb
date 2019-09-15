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

    let!(:ticket) { FactoryBot.create(:ticket, brand: brand) }

    let(:tweet) do
      double('Ticket', id: '1', text: 'does not matter', in_reply_to_tweet_id: ticket.external_uid,
                       user: double('Author', id: '2', screen_name: 'test'))
    end

    let(:client) do
      double('Client')
    end

    before do
      allow(controller).to receive(:brand).and_return(brand)
      allow(controller).to receive(:client).and_return(client)
      allow(client).to receive(:reply).and_return(tweet)
    end

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        FactoryBot.create(:account, user: user)

        allow(controller).to receive(:current_user).and_return(user)

        brand.users << user

        sign_in(user)
      end

      it 'replies to the ticket' do
        expect(client).to receive(:reply).with('does not matter', ticket.external_uid)

        post_reply
      end

      it 'creates a reply ticket' do
        expect { post_reply }.to change { Ticket.count }.from(1).to(2)
        expect(Ticket.last).to have_attributes(parent: ticket, content: 'does not matter')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(post_reply.request).to set_flash[:alert]
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
          expect { post_invert_status }.to change { ticket.status }.from('open').to('solved')
        end
      end

      context 'when the ticket is solved' do
        before do
          ticket.status = 'solved'
        end

        it 'opens the ticket' do
          expect { post_invert_status }.to change { ticket.status }.from('solved').to('open')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(post_invert_status.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(post_invert_status).to redirect_to(root_path)
      end
    end
  end

  describe 'POST refresh' do
    subject(:post_refresh) { post :refresh, params: { brand_id: brand.id } }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'calls the background worker' do
        expect(LoadNewTweetsJob).to receive(:perform_now)

        post_refresh
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(post_refresh.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(post_refresh).to redirect_to(root_path)
      end
    end
  end
end
