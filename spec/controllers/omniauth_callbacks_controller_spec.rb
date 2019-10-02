# frozen_string_literal: true

RSpec.describe OmniauthCallbacksController, type: :controller do
  describe 'GET authenticate' do
    subject(:get_authenticate) { get :authenticate, params: { provider: provider }, session: session }

    let(:session) { {} }

    let(:auth_hash) do
      fixture_name = case provider
                     when 'twitter'
                       'twitter_oauth_hash.json'
                     when 'google_oauth2'
                       'google_oauth_hash.json'
                     end
      JSON.parse(file_fixture(fixture_name).read, object_class: OpenStruct)
    end

    before do
      request.env['omniauth.auth'] = auth_hash
      request.env['omniauth.params'] = { 'model' => model }
    end

    context 'when model is user' do
      let(:model) { 'user' }

      %w[twitter google_oauth2].each do |provider_param|
        context "when provider is #{provider_param}" do
          let(:provider) { provider_param }

          before do
            request.env['omniauth.auth'].provider = provider
          end

          it 'redirects to root' do
            get_authenticate

            expect(controller).to redirect_to(root_path)
          end

          it 'sets the flash' do
            get_authenticate

            expect(controller).to set_flash[:notice].to('Successfully authenticated user.')
          end

          context 'when there is no account' do
            it 'creates a new account' do
              expect { get_authenticate }.to change(Account, :count).from(0).to(1)
            end
          end

          context 'when there is an account' do
            before do
              FactoryBot.create(:account, external_uid: auth_hash.uid, provider: provider)
            end

            it 'does not create a new account' do
              expect { get_authenticate }.not_to change(Account, :count).from(1)
            end
          end

          context 'when the user is not logged in' do
            it 'logs the user in' do
              expect { get_authenticate }.to change { controller.send(:user_signed_in?) }.from(false).to(true)
            end
          end
        end
      end
    end

    context 'when model is brand' do
      let(:model) { 'brand' }

      let(:provider) { 'twitter' }

      before do
        request.env['omniauth.auth'].provider = provider
      end

      context 'when user is logged in' do
        let(:user) { FactoryBot.create(:user) }
        let(:session) { { user_id: user.id } }

        it 'redirects to root' do
          get_authenticate

          expect(controller).to redirect_to(root_path)
        end

        it 'sets the flash' do
          get_authenticate

          expect(controller).to set_flash[:notice].to('Successfully authenticated brand.')
        end

        context 'when brand does not exist' do
          it 'creates a new brand' do
            expect { get_authenticate }.to change(Brand, :count).from(0).to(1)
          end
        end

        context 'when brand exists' do
          before do
            FactoryBot.create(:brand, external_uid: auth_hash.uid)
          end

          it 'does not create a new brand' do
            expect { get_authenticate }.not_to change(Brand, :count).from(1)
          end
        end
      end
    end
  end
end
