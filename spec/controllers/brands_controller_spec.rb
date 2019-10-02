# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe BrandsController, type: :controller do
  include SignInOutHelpers

  describe 'GET index' do
    subject(:get_index) { get :index }

    let!(:brands) { FactoryBot.create_list(:brand, 2) }

    context 'when user is not logged in' do
      it 'redirects the user' do
        expect(get_index).to redirect_to(root_path)
      end

      it 'sets the flash' do
        get_index

        expect(controller).to set_flash[:alert].to('You are not logged in.')
      end
    end

    context 'when user is logged in' do
      before do
        sign_in(FactoryBot.create(:user))
      end

      it 'sets the brands' do
        get_index

        expect(assigns(:brands)).to contain_exactly(*brands)
      end

      it 'sets the paginator' do
        get_index

        expect(assigns(:pagy)).not_to be_nil
      end

      it 'renders the index template' do
        expect(get_index).to render_template('brands/index')
      end

      context 'when pagination is required' do
        let!(:extra_brands) { FactoryBot.create_list(:brand, 19) }

        it 'paginates brands' do
          get_index

          expect(assigns(:brands)).to contain_exactly(*brands, *extra_brands.first(18))
        end
      end
    end
  end

  describe 'GET edit' do
    subject(:get_edit) { get :edit, params: { id: brand.id } }

    let(:brand) { FactoryBot.create(:brand) }

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'renders the edit template' do
        expect(get_edit).to render_template('brands/edit')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        get_edit

        expect(controller).to set_flash[:alert].to('You are not allowed to edit the brand.')
      end

      it 'redirects the user' do
        expect(get_edit).to redirect_to(root_path)
      end
    end
  end
end
