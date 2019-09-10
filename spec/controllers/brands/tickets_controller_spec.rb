# frozen_string_literal: true

RSpec.describe Brands::TicketsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:brand) { FactoryBot.create(:brand) }

  describe 'GET index' do
    subject { get :index, params: { brand_id: brand.id } }

    before do
      FactoryBot.create_list(:ticket, 2, brand: brand)
    end

    it 'sets the tickets' do
      subject

      expect(assigns(:tickets)).to eq(brand.tickets.root)
    end

    it 'renders the index template' do
      expect(subject).to render_template('brands/tickets/index', partial: 'twitter/_feed')
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
