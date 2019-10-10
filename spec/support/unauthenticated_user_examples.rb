# frozen_string_literal: true

RSpec.shared_examples 'unauthenticated user examples' do
  it 'sets the flash' do
    subject
    follow_redirect!

    expect(controller.flash[:alert]).to eq('You are not logged in.')
  end

  it 'redirects the user to root' do
    expect(subject).to redirect_to(root_path)
  end
end
