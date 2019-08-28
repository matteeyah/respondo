# frozen_string_literal: true

RSpec.describe 'brands/show', type: :view do
  let(:tweets) do
    [
      Brand::ThreadedTweet.new(1, nil, 'matija', 'Hello', []),
      Brand::ThreadedTweet.new(2, nil, 'other', 'World', [])
    ]
  end

  before do
    brand = FactoryBot.build(:brand)
    allow(brand).to receive(:threaded_mentions).and_return(tweets)
    assign(:brand, brand)
  end

  it 'renders the twitter feed' do
    expect(render).to render_template(partial: 'twitter/_feed')
  end
end
