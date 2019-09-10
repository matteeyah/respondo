# frozen_string_literal: true

RSpec.describe 'home/index', type: :view do
  context 'when user is signed in' do
    before do
      assign(:user_brand, FactoryBot.create(:brand))
    end

    it 'renders the brand tickets' do
      expect(render).to have_link('Brand Tickets')
    end
  end

  context 'when user is not signed in' do
    it 'does not render the brand tickets' do
      expect(render).not_to have_link('Brand Tickets')
    end
  end
end
