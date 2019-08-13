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

  describe '#twitter' do
    subject { get :twitter }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when brand is sourced' do
      let(:brand) { FactoryBot.create(:brand) }

      before do
        allow(Brand).to receive(:from_omniauth).and_return(brand)
      end

      it 'is expected to set the notice flash' do
        subject

        expect(controller).to set_flash[:notice]
      end
    end

    context 'when brand creation fails' do
      before do
        allow(Brand).to receive(:from_omniauth).and_return(Brand.new)
      end

      it 'is expected to set the notice flash' do
        subject

        expect(controller).to set_flash[:notice]
      end

      it { is_expected.to redirect_to(root_path) }
    end
  end
end
