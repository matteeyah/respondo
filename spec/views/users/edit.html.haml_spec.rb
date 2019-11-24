# frozen_string_literal: true

RSpec.describe 'users/edit', type: :view do
  let(:user) { FactoryBot.create(:user) }

  before do
    FactoryBot.create(:user_account, provider: 'google_oauth2', user: user)
    FactoryBot.create(:personal_access_token, name: 'something_nice', user: user)

    without_partial_double_verification do
      allow(view).to receive(:user).and_return(user)
    end
  end

  it 'renders the authorize twitter link' do
    expect(render).to have_link('Authorize Twitter')
  end

  it 'renders remove account link' do
    expect(render).to have_link('Remove Google')
  end

  it 'renders the new personal access tokens form' do
    expect(render).to have_field(:name).and have_button('Create')
  end

  it 'renders the remove personal access token link' do
    expect(render).to have_link('Remove something_nice')
  end
end
