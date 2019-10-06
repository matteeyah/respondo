# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe BrandsController, type: :request do
  include SignInOutHelpers

  describe 'GET index' do
    subject(:get_index) { get '/brands' }

    let!(:brands) { FactoryBot.create_list(:brand, 2) }

    context 'when user is authenticated' do
      before do
        sign_in(FactoryBot.create(:user, :with_account))
      end

      it 'shows the first page of brands' do
        get_index

        expect(response.body).to include(*brands.map(&:screen_name))
      end

      context 'when pagination is required' do
        let!(:extra_brands) { FactoryBot.create_list(:brand, 19) }

        it 'paginates brands' do
          get_index

          expect(response.body).to include(*(brands + extra_brands.first(18)).map(&:screen_name))
        end
      end
    end

    context 'when user is not authenticated' do
      it 'sets the flash' do
        get_index
        follow_redirect!

        expect(controller.flash[:alert]).to eq('You are not logged in.')
      end

      it 'redirects the user' do
        expect(get_index).to redirect_to(root_path)
      end
    end
  end

  describe 'GET edit' do
    subject(:get_edit) { get "/brands/#{brand.id}/edit" }

    let(:brand) { FactoryBot.create(:brand) }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user, :with_account) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'renders the users list' do
        get_edit

        expect(response.body).to include(*brand.users.map(&:name))
      end

      it 'renders the add user button' do
        get_edit

        expect(response.body).to include('Add User')
      end

      it 'renders the remove user link' do
        get_edit

        expect(response.body).to include('Remove User')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        get_edit
        follow_redirect!

        expect(controller.flash[:alert]).to eq('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(get_edit).to redirect_to(root_path)
      end
    end
  end
end
