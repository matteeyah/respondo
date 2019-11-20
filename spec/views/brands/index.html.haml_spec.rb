# frozen_string_literal: true

RSpec.describe 'brands/index', type: :view do
  let(:brands) { FactoryBot.create_list(:brand, 2) }

  before do
    assign(:brands, brands)

    allow(view).to receive(:pagy_bootstrap_nav)
  end

  it 'renders all brands' do
    expect(render).to have_text(brands.first.screen_name).and have_text(brands.second.screen_name)
  end

  it 'renders brand tickets links' do
    expect(render).to have_link(brands.first.screen_name, href: brand_tickets_path(brands.first))
      .and have_link(brands.second.screen_name, href: brand_tickets_path(brands.second))
  end

  it 'renders brands search form' do
    expect(render).to have_field('query').and have_button('Search')
  end
end
