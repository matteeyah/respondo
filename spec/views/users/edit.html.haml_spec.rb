# frozen_string_literal: true

RSpec.describe 'users/edit', type: :view do
  let(:user) { FactoryBot.create(:user) }
  let!(:account) { FactoryBot.create(:account, provider: 'google_oauth2', user: user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:user).and_return(user)
    end
  end

  it 'renders all accounts' do
    expect(render).to have_text(account.provider)
  end

  it 'has the authorize twitter link' do
    expect(render).to have_link('Authorize Twitter')
  end

  it 'has the remove account link' do
    expect(render).to have_link('Remove Account', href: user_account_path(user, account))
  end
end
