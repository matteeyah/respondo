# frozen_string_literal: true

RSpec.describe 'home/index' do
  include Devise::Test::ControllerHelpers

  context 'when user is signed in' do
    let(:user) { FactoryBot.build(:user) }

    before do
      allow(view).to receive(:current_user).and_return(user)
    end

    context 'when user has associated brand' do
      let(:brand) { FactoryBot.build(:brand) }

      let(:mentions) do
        [
          Brand::ThreadedTweet.new(1, nil, 'matija', 'Hello', []),
          Brand::ThreadedTweet.new(2, nil, 'other', 'World', [])
        ]
      end

      before do
        allow(brand).to receive(:mentions).and_return(mentions)
        user.brand = brand
      end

      it 'displays all the tweets' do
        assign(:brand, brand)

        render

        expect(rendered).to have_text 'Tweets'
        expect(rendered).to have_text 'matija: Hello'
        expect(rendered).to have_text 'other: World'
      end
    end
  end

  context 'when user is not signed in' do
    it 'does not display tweets' do
      render

      expect(rendered).not_to have_text 'Tweets'
    end
  end
end
