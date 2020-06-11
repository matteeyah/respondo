# frozen_string_literal: true

RSpec.shared_examples 'unsubscribed brand examples' do
  it 'sets the warning flash' do
    subject
    follow_redirect!

    expect(controller.flash[:warning]).to eq('You do not have an active subscription.')
  end

  it 'redirects the user back (to root)' do
    expect(subject).to redirect_to(root_path)
  end
end
