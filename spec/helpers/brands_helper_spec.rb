# frozen_string_literal: true

RSpec.describe BrandsHelper, type: :helper do
  describe '#add_users_dropdown_options_for' do
    subject(:add_users_dropdown_options_for) { helper.add_users_dropdown_options_for }

    let(:brand) { FactoryBot.create(:brand) }
    let(:user_in_brand) { FactoryBot.create(:user) }
    let(:user_in_other_brand) { FactoryBot.create(:user) }
    let!(:user_without_brand) { FactoryBot.create(:user) }

    before do
      brand.users << user_in_brand
      FactoryBot.create(:brand).users << user_in_other_brand
    end

    it 'returns just users outside brand' do
      expect(add_users_dropdown_options_for).to contain_exactly([user_without_brand.name, user_without_brand.id])
    end
  end

  describe '#user_authorized_for?' do
    subject(:user_authorized_for?) { helper.user_authorized_for?(user, brand) }

    let(:brand) { FactoryBot.build(:brand) }

    context 'when user is not nil' do
      let(:user) { FactoryBot.build(:user) }

      context 'when user is part of the brand' do
        before do
          brand.users << user
        end

        it { is_expected.to eq(true) }
      end

      context 'when user is not part of the brand' do
        it { is_expected.to eq(false) }
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it { is_expected.to eq(false) }
    end
  end

  describe '#user_can_reply_to?' do
    subject(:user_can_reply_to?) { helper.user_can_reply_to?(user, provider) }

    context 'when user is not nil' do
      let(:user) { FactoryBot.create(:user) }

      context 'when user has account' do
        before do
          FactoryBot.create(:user_account, provider: provider, user: user)
        end

        context 'when account has client' do
          let(:provider) { 'twitter' }

          it { is_expected.to eq(true) }
        end

        context 'when account does not have client' do
          let(:provider) { 'google_oauth2' }

          it { is_expected.to eq(false) }
        end
      end

      context 'when user does not have account' do
        let(:provider) { 'something_else' }

        it { is_expected.to eq(false) }
      end
    end

    context 'when user is nil' do
      let(:user) { nil }
      let(:provider) { 'something_else' }

      it { is_expected.to eq(false) }
    end
  end

  describe '#subscription_badge_class' do
    subject(:subscription_badge_class) { helper.subscription_badge_class(subscription_status) }

    [[nil, 'danger'], %w[deleted danger], %w[trialing warning], %w[active success]].each do |status_pair|
      context "when subscription is #{status_pair.first}" do
        let(:subscription_status) { status_pair.first }

        it { is_expected.to eq(status_pair.second) }
      end
    end
  end
end
