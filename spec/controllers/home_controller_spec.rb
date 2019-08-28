# frozen_string_literal: true

RSpec.describe HomeController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'GET index' do
    subject { get :index }

    it 'renders the home page' do
      expect(subject).to render_template('home/index')
    end
  end
end
