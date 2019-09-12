# frozen_string_literal: true

RSpec.describe SessionsController, type: :controller do
  describe 'GET create' do
    let(:user) { double('User', id: 1, persisted?: true) }

    subject(:get_create) { get :create, params: { provider: provider } }

    before do
      allow(User).to receive(:from_omniauth).and_return(user)
    end

    context 'when oauth is from google' do
      let(:provider) { 'google_oauth2' }

      before do
        request.env['omniauth.auth'] = JSON.parse(file_fixture('google_user_oauth_hash.json').read, object_class: OpenStruct)
      end

      it 'procures a user model' do
        expect(User).to receive(:from_omniauth).once

        get_create
      end

      it 'logs the user in' do
        expect { get_create }.to change { session[:user_id] }.from(nil).to(user.id)
      end

      it 'sets a flash' do
        get_create

        expect(controller).to set_flash[:notice]
      end

      it 'redirects to root' do
        get_create

        expect(controller).to redirect_to(root_path)
      end
    end

    context 'when oauth is from twitter' do
      let(:provider) { 'twitter' }

      before do
        request.env['omniauth.auth'] = JSON.parse(file_fixture('twitter_brand_oauth_hash.json').read, object_class: OpenStruct)

        brand = double('Brand', persisted?: true)
        allow(Brand).to receive(:from_omniauth).and_return(brand)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'procures a brand model' do
        expect(Brand).to receive(:from_omniauth).once

        get_create
      end

      it 'sets a flash' do
        get_create

        expect(controller).to set_flash[:notice]
      end

      it 'redirects to root' do
        get_create

        expect(controller).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_destroy) { delete :destroy }

    before do
      session[:user_id] = 1
    end

    it 'redirects back to root' do
      expect(delete_destroy).to redirect_to(root_path)
    end

    it 'logs the user out' do
      expect { delete_destroy }.to change { session[:user_id] }.from(1).to(nil)
    end
  end
end
