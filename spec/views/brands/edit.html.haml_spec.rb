# frozen_string_literal: true

require './spec/support/concerns/views/_accounts_examples.rb'

RSpec.describe 'brands/edit', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:user_in_brand) { FactoryBot.create(:user) }
  let!(:user_outside_brand) { FactoryBot.create(:user) }

  before do
    brand.users << user_in_brand
    assign(:brand_users, [user_in_brand])

    allow(view).to receive(:pagy_bootstrap_nav)

    without_partial_double_verification do
      allow(view).to receive(:brand).and_return(brand)
    end
  end

  it_behaves_like '_accounts_partial', Brand

  it 'has the add user select box' do
    expect(render).to have_select('add-user', options: ['Select user', user_outside_brand.name])
  end

  it 'has the remove user link' do
    expect(render).to have_link("Remove #{user_in_brand.name}", href: brand_user_path(brand, user_in_brand.id))
  end

  it 'has the brand domain text field' do
    expect(render).to have_selector('input[name="brand[domain]"]')
  end
end
