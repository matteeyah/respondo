# frozen_string_literal: true

RSpec.shared_examples 'unauthorized user examples' do |alert_message|
  it 'sets the flash' do
    subject
    follow_redirect!

    expect(controller.flash[:alert]).to eq(alert_message)
  end

  it 'redirects the user to root' do
    expect(subject).to redirect_to(root_path)
  end
end
