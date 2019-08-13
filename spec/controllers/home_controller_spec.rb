# frozen_string_literal: true

Rspec.describe HomeController, type: :controller do
  describe 'GET index' do
    subject { get :index }

    it 'renders the home page' do
      expect(response).to have_http_status(200)
    end
  end
end
