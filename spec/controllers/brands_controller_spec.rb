# frozen_string_literal: true

require './spec/support/sign_in_out_helpers.rb'

RSpec.describe BrandsController, type: :controller do
  include SignInOutHelpers

  describe 'GET index' do
    subject(:get_index) { get :index }

    let!(:brands) { FactoryBot.create_list(:brand, 2) }

    it 'sets the brands' do
      get_index

      expect(assigns(:brands)).to contain_exactly(*brands)
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

  describe 'GET edit' do
    subject(:get_edit) { get :edit, params: { id: brand.id } }

    let(:brand) { FactoryBot.create(:brand) }

    it 'sets the brand' do
      get_edit

      expect(assigns(:brand)).to eq(brand)
    end

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
        expect(get_edit.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(get_edit).to redirect_to(root_path)
      end
    end
  end
end
