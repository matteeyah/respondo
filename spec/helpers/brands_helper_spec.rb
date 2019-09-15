# frozen_string_literal: true

RSpec.describe BrandsHelper, type: :helper do
  let!(:brand) { FactoryBot.create(:brand) }

  before do
    assign(:brand, brand)
  end

  describe '#add_users_dropdown_options' do
    let!(:user_in_brand) { FactoryBot.create(:user) }
    let!(:user_outside_brand) { FactoryBot.create(:user) }

    before do
      brand.users << user_in_brand

      without_partial_double_verification do
        allow(helper).to receive(:current_brand).and_return(brand)
      end
    end

    subject { helper.add_users_dropdown_options }

    it 'returns just users outside brand' do
      expect(subject).to contain_exactly([user_outside_brand.name, user_outside_brand.id])
    end
  end

  describe '#authorized_for?' do
    subject(:authorized_for?) { helper.authorized_for?(brand) }

    before do
      # The helper does not implement current_brand so we can not mock it
      # It's inherited as a helper method from the ApplicationController
      # Tets use an anonymous controller which is why it's not there
      without_partial_double_verification do
        allow(helper).to receive(:current_brand).and_return(logged_in_brand)
      end
    end

    context 'when thre is no logged in brand' do
      let(:logged_in_brand) { nil }

      it { is_expected.to eq(false) }
    end

    context 'when the logged in brand is not the current one' do
      let(:logged_in_brand) { FactoryBot.create(:brand) }

      it { is_expected.to eq(false) }
    end

    context 'when the logged in brand is the current one' do
      let(:logged_in_brand) { brand }

      it { is_expected.to eq(true) }
    end
  end

  describe '#user_has_account_for?' do
    let(:user) { FactoryBot.create(:user) }

    subject(:user_has_account_for?) { helper.user_has_account_for?('twitter') }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_user).and_return(user)
      end
    end

    context 'when user has account' do
      before do
        FactoryBot.create(:account, user: user)
      end

      it { is_expected.to eq(true) }
    end

    context 'when user does not have account' do
      it { is_expected.to eq(false) }
    end
  end
end
