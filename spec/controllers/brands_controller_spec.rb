# frozen_string_literal: true

RSpec.describe BrandsController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'GET index' do
    let!(:brands) { FactoryBot.create_list(:brand, 2) }

    subject { get :index }

    it 'sets the brands' do
      subject

      expect(assigns(:brands)).to contain_exactly(*brands)
    end

    it 'renders the correct template' do
      expect(subject).to render_template('brands/index')
    end

    context 'when pagination is required' do
      let!(:extra_brands) { FactoryBot.create_list(:brand, 19) }

      it 'paginates brands' do
        subject

        expect(assigns(:brands)).to contain_exactly(*brands, *extra_brands.first(18))
        expect(assigns(:pagy)).not_to be_nil
      end
    end
  end

  describe 'GET show' do
    let(:brand) { FactoryBot.create(:brand) }

    subject { get :show, params: { id: brand.id } }

    it 'sets the brand' do
      subject

      expect(assigns(:brand)).to eq(brand)
    end

    it 'renders the correct template' do
      expect(subject).to render_template('brands/show', partial: 'twitter/_feed')
    end
  end
end
