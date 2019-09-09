# frozen_string_literal: true

RSpec.describe 'home/index', type: :view do
  include Devise::Test::ControllerHelpers

  context 'when user is signed in' do
    let(:user) { FactoryBot.build(:user) }

    before do
      allow(view).to receive(:current_user).and_return(user)
    end

    context 'when user has associated brand' do
      let(:brand) { FactoryBot.build(:brand) }

      before do
        user.brand = brand
      end

      it 'renders the brand tickets' do
        expect(render).to render_template('home/index', partial: 'brands/_tickets')
      end
    end

    context 'when user does not have associated brand' do
      it 'does not render the brand tickets' do
        expect(render).not_to render_template(partial: 'brands/_tickets')
      end
    end
  end

  context 'when user is not signed in' do
    it 'does not render the brand tickets' do
      expect(render).not_to render_template(partial: 'brands/_tickets')
    end
  end
end
