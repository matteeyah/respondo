# frozen_string_literal: true

RSpec.describe 'brands/edit', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let!(:user_in_brand) { FactoryBot.create(:user) }
  let!(:user_outside_brand) { FactoryBot.create(:user) }

  before do
    brand.users << user_in_brand

    assign(:brand, brand)

    without_partial_double_verification do
      allow(view).to receive(:current_brand).and_return(brand)
    end
  end

  it 'renders all users' do
    expect(render).to have_text(user_in_brand.name)
  end

  it 'has the add user select box' do
    expect(render).to have_select('add-user', options: [user_outside_brand.name])
  end

  it 'has the remove user link' do
    expect(render).to have_link('Remove User', href: brand_user_path(brand, user_in_brand.id))
  end
end
