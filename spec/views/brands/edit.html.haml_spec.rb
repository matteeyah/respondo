# frozen_string_literal: true

RSpec.describe 'brands/edit', type: :view do
  let(:brand) { FactoryBot.create(:brand) }

  let!(:first_user) { FactoryBot.create(:user) }
  let!(:second_user) { FactoryBot.create(:user) }

  before do
    brand.users << first_user

    assign(:brand, brand)
  end

  it 'renders all users' do
    expect(render).to have_text(first_user.name)
  end

  it 'has the add user select box' do
    expect(render).to have_select('add-user', options: [second_user.name])
  end

  it 'has the remove user select box' do
    expect(render).to have_select('remove-user', options: [first_user.name])
  end
end
