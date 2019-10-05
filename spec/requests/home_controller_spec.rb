# frozen_string_literal: true

RSpec.describe HomeController, type: :request do
  describe 'GET index' do
    subject(:get_index) { get '/' }

    it 'renders the home page' do
      expect(get_index).to render_template('home/index')
    end
  end
end
