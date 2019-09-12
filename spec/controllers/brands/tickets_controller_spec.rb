# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe Brands::TicketsController, type: :controller do
  include SignInOutHelpers

  let(:brand) { FactoryBot.create(:brand) }

  describe 'GET index' do
    subject { get :index, params: { brand_id: brand.id } }

    before do
      FactoryBot.create(:ticket, status: :open, brand: brand)
      FactoryBot.create(:ticket, status: :solved, brand: brand)
    end

    it 'sets open tickets' do
      subject

      expect(assigns(:open_tickets)).to eq(brand.tickets.root.open)
    end

    it 'sets solved tickets' do
      subject

      expect(assigns(:solved_tickets)).to eq(brand.tickets.root.solved)
    end

    it 'renders the index template' do
      expect(subject).to render_template('brands/tickets/index', partial: 'twitter/_feed')
    end
  end

  describe 'POST reply' do
    let!(:ticket) { FactoryBot.create(:ticket) }

    let(:tweet) do
      double('Ticket', id: '1', text: 'does not matter', in_reply_to_tweet_id: ticket.external_uid,
                       user: double('Author', id: '2', screen_name: 'test'))
    end

    subject { post :reply, params: { brand_id: brand.id, ticket_id: ticket.id, response_text: 'does not matter' } }

    before do
      allow(controller).to receive(:brand).and_return(brand)
      allow(brand).to receive(:reply).and_return(tweet)
    end

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'replies to the ticket' do
        expect(brand).to receive(:reply).with('does not matter', ticket.external_uid)

        subject
      end

      it 'creates a reply ticket' do
        expect { subject }.to change { Ticket.count }.from(1).to(2)
        expect(Ticket.last).to have_attributes(parent: ticket, content: 'does not matter')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(subject.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end

  describe 'POST invert_status' do
    let(:ticket) { FactoryBot.create(:ticket) }

    subject { post :invert_status, params: { brand_id: brand.id, ticket_id: ticket.id } }

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
          expect { subject }.to change { ticket.status }.from('open').to('solved')
        end
      end

      context 'when the ticket is solved' do
        before do
          ticket.status = 'solved'
        end

        it 'opens the ticket' do
          expect { subject }.to change { ticket.status }.from('solved').to('open')
        end
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(subject.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end

  describe 'POST refresh' do
    subject { post :refresh, params: { brand_id: brand.id } }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'calls the background worker' do
        expect(LoadNewTicketsJob).to receive(:perform_now)

        subject
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(subject.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end
end
