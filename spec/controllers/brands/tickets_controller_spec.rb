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
end
