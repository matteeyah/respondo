# frozen_string_literal: true

RSpec.describe Brands::UsersController, type: :controller do
  let(:brand) { FactoryBot.create(:brand) }

  describe 'POST create' do
    let(:user) { FactoryBot.create(:user) }

    subject { post :create, params: { brand_id: brand.id, user_id: user.id } }

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

  describe 'DELETE destroy' do
    let(:user) { FactoryBot.create(:user) }

    before do
      brand.users << user
    end

    subject { delete :destroy, params: { brand_id: brand.id, id: user.id } }

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
end
