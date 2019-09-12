# frozen_string_literal: true

RSpec.describe BrandsController, type: :controller do
  describe 'GET index' do
    let!(:brands) { FactoryBot.create_list(:brand, 2) }

    subject { get :index }

    it 'sets the brands' do
      subject

      expect(assigns(:brands)).to contain_exactly(*brands)
    end

    it 'renders the index template' do
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

  describe 'GET edit' do
    let(:brand) { FactoryBot.create(:brand) }

    subject { get :edit, params: { id: brand.id } }

    it 'sets the brand' do
      subject

      expect(assigns(:brand)).to eq(brand)
    end

    context 'when user is authorized' do
      let(:user) { FactoryBot.create(:user) }

      before do
        brand.users << user

        sign_in(user)
      end

      it 'renders the edit template' do
        expect(subject).to render_template('brands/edit')
      end
    end

    context 'when user is not authorized' do
      it 'sets the flash' do
        expect(subject.request).to set_flash[:alert]
      end

      it 'redirects the user' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end
end
