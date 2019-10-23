# frozen_string_literal: true

RSpec.describe 'users/edit', type: :view do
  let(:user) { FactoryBot.create(:user) }

  before do
    FactoryBot.create(:account, provider: 'google_oauth2', user: user)

    without_partial_double_verification do
      allow(view).to receive(:user).and_return(user)
    end
  end

  it 'has the remove account link' do
    expect(render).to have_link('Remove Google')
  end

  it 'has the authorize twitter link' do
    expect(render).to have_link('Authorize Twitter')
  end
end
