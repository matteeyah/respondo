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

  describe 'GET show' do
    let(:brand) { FactoryBot.create(:brand) }

    subject { get :show, params: { id: brand.id } }

    it 'sets the brand' do
      subject

      expect(assigns(:brand)).to eq(brand)
    end

    it 'renders the show template' do
      expect(subject).to render_template('brands/show', partial: 'twitter/_feed')
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

  describe 'POST add_user' do
    let(:brand) { FactoryBot.create(:brand) }
    let(:user) { FactoryBot.create(:user) }

    subject { post :add_user, params: { brand_id: brand.id, user_id: user.id } }

    it 'sets the brand' do
      subject

      expect(assigns(:brand)).to eq(brand)
    end

    it 'sets the user' do
      subject

      expect(assigns(:user)).to eq(user)
    end

    context 'when user is authorized' do
      let(:browsing_user) { FactoryBot.create(:user) }

      before do
        brand.users << browsing_user

        sign_in(browsing_user)
      end

      it 'adds the user to the brand' do
        expect(brand.users).not_to include(user)

        subject

        expect(brand.reload.users).to include(user)
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

  describe 'POST remove_user' do
    let(:brand) { FactoryBot.create(:brand) }
    let(:user) { FactoryBot.create(:user) }

    before do
      brand.users << user
    end

    subject { post :remove_user, params: { brand_id: brand.id, user_id: user.id } }

    it 'sets the brand' do
      subject

      expect(assigns(:brand)).to eq(brand)
    end

    it 'sets the user' do
      subject

      expect(assigns(:user)).to eq(user)
    end

    context 'when user is authorized' do
      let(:browsing_user) { FactoryBot.create(:user) }

      before do
        brand.users << browsing_user

        sign_in(browsing_user)
      end

      it 'removes the user from the brand' do
        expect(brand.users).to include(user)

        subject

        expect(brand.reload.users).not_to include(user)
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

  describe 'POST refresh_tickets' do
    let(:brand) { FactoryBot.create(:brand) }

    subject { post :refresh_tickets, params: { brand_id: brand.id } }

    it 'calls the background worker' do
      expect(LoadTicketsJob).to receive(:perform_now)

      subject
    end
  end
end
