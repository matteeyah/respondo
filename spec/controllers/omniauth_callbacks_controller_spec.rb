# frozen_string_literal: true

RSpec.describe OmniauthCallbacksController, type: :controller do
  describe 'GET create' do
    subject(:get_create) { get :create, params: { provider: provider } }

    context 'when oauth is from google' do
      let(:provider) { 'google_oauth2' }

      before do
        request.env['omniauth.auth'] = JSON.parse(file_fixture('google_user_oauth_hash.json').read, object_class: OpenStruct)
      end

      it 'logs the user in' do
        expect { get_create }.to change { controller.send(:user_signed_in?) }.from(false).to(true)
      end

      it 'sets the flash' do
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
      end

      context 'when the user is signed in' do
        before do
          allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user))
        end

        it 'logs the brand in' do
          expect { get_create }.to change { controller.send(:brand_signed_in?) }.from(false).to(true)
        end

        it 'sets the flash' do
          get_create

          expect(controller).to set_flash[:notice]
        end

        it 'redirects to root' do
          get_create

          expect(controller).to redirect_to(root_path)
        end
      end

      context 'when the user is not signed in' do
        it 'does not log the brand in' do
          expect { get_create }.not_to change { controller.send(:brand_signed_in?) }.from(false)
        end

        it 'does not set the flash' do
          get_create

          expect(controller).not_to set_flash[:notice]
        end

        it 'redirects to root' do
          get_create

          expect(controller).to redirect_to(root_path)
        end
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
