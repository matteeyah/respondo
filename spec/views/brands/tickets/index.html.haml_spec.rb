# frozen_string_literal: true

RSpec.describe 'brands/tickets/index', type: :view do
  let(:brand) { FactoryBot.create(:brand) }

  before do
    assign(:brand, brand)
    assign(:tickets, [])
  end

  it 'renders the tickets' do
    expect(render).to render_template(partial: 'brands/tickets/_tickets')
  end

  context 'when user is authorized' do
    before do
      assign(:user_brand, brand)
    end

    it 'renders the refresh button' do
      expect(render).to have_button('Refresh Tickets')
    end
  end

  context 'when user is not authorized' do
    it 'does not render the refresh button' do
      expect(render).not_to have_button('Refresh Tickets')
    end
  end
end
