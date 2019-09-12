# frozen_string_literal: true

RSpec.describe 'home/index', type: :view do
  context 'when user is signed in' do
    before do
      # The view does not implement current_brand so we can not mock it
      # It's inherited as a helper method from the ApplicationController
      # Tets use an anonymous controller which is why it's not there
      without_partial_double_verification do
        allow(view).to receive(:current_brand).and_return(FactoryBot.create(:brand))
      end
    end

    it 'renders the brand tickets' do
      expect(render).to have_link('Brand Tickets')
    end
  end

  context 'when user is not signed in' do
    before do
      without_partial_double_verification do
        allow(view).to receive(:current_brand).and_return(nil)
      end
    end

    it 'does not render the brand tickets' do
      expect(render).not_to have_link('Brand Tickets')
    end
  end
end
