# frozen_string_literal: true

RSpec.describe HomeController, type: :controller do
  describe 'GET index' do
    subject(:get_index) { get :index }

    it 'renders the home page' do
      expect(get_index).to render_template('home/index')
    end
  end
end
