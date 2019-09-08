# frozen_string_literal: true

RSpec.describe 'brands/show', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:tweets) { FactoryBot.create_list(:ticket, 2, brand: brand) }

  before do
    assign(:brand, brand)
  end

  it 'renders the twitter feed' do
    expect(render).to render_template(partial: 'twitter/_feed')
  end
end
