# frozen_string_literal: true

RSpec.describe 'home/index', type: :view do
  before do
    without_partial_double_verification do
      allow(view).to receive(:current_brand).and_return(brand)
    end
  end

  context 'when brand is signed in' do
    let(:brand) { FactoryBot.create(:brand) }

    it 'renders the brand tickets' do
      expect(render).to have_link('Brand Tickets')
    end
  end

  context 'when brand is not signed in' do
    let(:brand) { nil }

    it 'does not render the brand tickets' do
      expect(render).not_to have_link('Brand Tickets')
    end
  end
end
