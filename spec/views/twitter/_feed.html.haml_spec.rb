# frozen_string_literal: true

RSpec.describe 'twitter/_feed', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:tweets) { FactoryBot.create_list(:ticket, 2, brand: brand) }

  subject { render partial: 'twitter/feed', locals: { tweets: tweets } }

  it 'displays all the tweets' do
    subject

    expect(rendered).to have_text "#{tweets.first.author.username}: #{tweets.first.content}"
    expect(rendered).to have_text "#{tweets.second.author.username}: #{tweets.second.content}"
  end
end
