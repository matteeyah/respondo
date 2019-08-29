# frozen_string_literal: true

RSpec.describe BrandsHelper, type: :helper do
  let!(:first_user) { FactoryBot.create(:user) }
  let!(:second_user) { FactoryBot.create(:user) }
  let!(:brand) { FactoryBot.create(:brand) }

  before do
    brand.users << first_user

    assign(:brand, brand)
  end

  describe '#remove_users_dropdown_options' do
    subject { helper.remove_users_dropdown_options }

    it 'returns users in brand' do
      expect(subject).to contain_exactly([first_user.name, first_user.id])
    end

    it 'does not return users outside brand' do
      expect(subject).not_to contain_exactly([second_user.name, second_user.id])
    end
  end

  describe '#add_users_dropdown_options' do
    subject { helper.add_users_dropdown_options }

    it 'returns users outside brand' do
      expect(subject).to contain_exactly([second_user.name, second_user.id])
    end

    it 'does not contain users in brand' do
      expect(subject).not_to contain_exactly([first_user.name, first_user.id])
    end
  end
end
