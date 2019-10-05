# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe UsersController, type: :request do
  include SignInOutHelpers

  describe 'GET edit' do
    subject(:get_edit) { get "/users/#{user.id}/edit" }

    let(:user) { FactoryBot.create(:user, :with_account) }

    context 'when user is authorized' do
      before do
        sign_in(user)
      end

      it 'renders the edit template' do
        expect(get_edit).to render_template('users/edit')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        get_edit
        follow_redirect!

        expect(controller.flash[:alert]).to eq('You are not allowed to edit the user.')
      end

      it 'redirects the user' do
        expect(get_edit).to redirect_to(root_path)
      end
    end
  end
end
