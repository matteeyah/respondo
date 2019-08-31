# frozen_string_literal: true

RSpec.describe BrandsHelper, type: :helper do
  let!(:user_in_brand) { FactoryBot.create(:user) }
  let!(:user_outside_brand) { FactoryBot.create(:user) }
  let!(:brand) { FactoryBot.create(:brand) }

  before do
    brand.users << user_in_brand

    assign(:brand, brand)
  end

  describe '#remove_users_dropdown_options' do
    subject { helper.remove_users_dropdown_options }

    it 'returns just users in brand' do
      expect(subject).to contain_exactly([user_in_brand.name, user_in_brand.id])
    end
  end

  describe '#add_users_dropdown_options' do
    subject { helper.add_users_dropdown_options }

    it 'returns just users outside brand' do
      expect(subject).to contain_exactly([user_outside_brand.name, user_outside_brand.id])
    end
  end
end
