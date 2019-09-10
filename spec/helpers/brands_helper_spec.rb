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
    end

    subject { helper.add_users_dropdown_options }

    it 'returns just users outside brand' do
      expect(subject).to contain_exactly([user_outside_brand.name, user_outside_brand.id])
    end
  end
end
