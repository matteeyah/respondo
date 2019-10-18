# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'
require './spec/support/unauthenticated_user_examples.rb'
require './spec/support/unauthorized_user_examples.rb'

RSpec.describe BrandsController, type: :request do
  include SignInOutHelpers

  describe 'GET index' do
    subject(:get_index) { get '/brands' }

    context 'when pagination is not required' do
      let!(:brands) { FactoryBot.create_list(:brand, 2) }

      it 'shows the first page of brands' do
        get_index

        expect(response.body).to include(*brands.map(&:screen_name))
      end
    end

    context 'when pagination is required' do
      let!(:brands) { FactoryBot.create_list(:brand, 21) }

      it 'paginates brands' do
        get_index

        expect(response.body).to include(*brands.first(20).map(&:screen_name))
      end

      it 'does not show page two brands' do
        get_index

        expect(response.body).not_to include(brands.last.screen_name)
      end
    end
  end

  describe 'GET edit' do
    subject(:get_edit) { get "/brands/#{brand.id}/edit" }

    let(:brand) { FactoryBot.create(:brand) }

    context 'when user is signed in' do
      let(:user) { FactoryBot.create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
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
        include_examples 'unauthorized user examples', 'You are not allowed to edit the brand.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthenticated user examples'
    end
  end
end
