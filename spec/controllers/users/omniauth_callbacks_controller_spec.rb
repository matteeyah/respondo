# frozen_string_literal: true

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe '#google_oauth2' do
    subject { get :google_oauth2 }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when user is sourced' do
      let(:user) { FactoryBot.create(:user) }

      before do
        allow(User).to receive(:from_omniauth).and_return(user)
      end

      it 'is expected to set the notice flash' do
        subject

        expect(controller).to set_flash[:notice]
      end

      it 'logins the user' do
        expect { subject }.to change { controller.current_user }.from(nil).to(user)
      end
    end

    context 'when user creation fails' do
      before do
        allow(User).to receive(:from_omniauth).and_return(User.new)
      end

      it 'is expected to set the notice flash' do
        subject

        expect(controller).to set_flash[:notice]
      end

      it 'does not login the user' do
        expect { subject }.not_to change { controller.current_user }.from(nil)
      end

      it { is_expected.to redirect_to(root_path) }
    end
  end
end
