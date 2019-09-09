# frozen_string_literal: true

RSpec.describe 'brands/_tickets', type: :view do
  let(:brand) { FactoryBot.create(:brand) }

  subject { render partial: 'brands/tickets', locals: { brand: brand } }

  it 'renders the twitter feed' do
    subject

    expect(rendered).to render_template(partial: 'twitter/_feed')
  end

  it 'renders the refresh button' do
    subject

    expect(rendered).to have_button('Refresh Tickets')
  end
end
