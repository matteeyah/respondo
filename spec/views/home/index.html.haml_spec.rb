# frozen_string_literal: true

RSpec.describe 'home/index', type: :view do
  before do
    without_partial_double_verification do
      allow(view).to receive(:current_brand).and_return(brand)
      allow(view).to receive(:user_signed_in?).and_return(user_logged_in)
    end
  end

  context 'when user is logged out' do
    let(:brand) { nil }
    let(:user_logged_in) { false }

    it 'renders the login link' do
      expect(render).to have_link('Login')
    end
  end

  context 'when the user is logged in' do
    let(:user_logged_in) { true }

    context 'when brand is not signed in' do
      let(:brand) { nil }

      it 'renders the authorize brand link' do
        expect(render).to have_link('Authorize Brand')
      end
    end

    context 'when brand is signed in' do
      let(:brand) { FactoryBot.create(:brand) }

      it 'renders the brand tickets link' do
        expect(render).to have_link('Brand Tickets')
      end
    end
  end
end
