# frozen_string_literal: true

RSpec.describe 'twitter/feed', type: :view do
  let(:tweets) do
    [
      Brand::ThreadedTweet.new(1, nil, 'matija', 'Hello', []),
      Brand::ThreadedTweet.new(2, nil, 'other', 'World', [])
    ]
  end

  subject { render partial: 'twitter/feed', locals: { tweets: tweets } }

  it 'displays all the tweets' do
    subject

    expect(rendered).to have_text 'matija: Hello'
    expect(rendered).to have_text 'other: World'
  end
end
