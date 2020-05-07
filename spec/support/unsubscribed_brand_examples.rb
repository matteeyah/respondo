# frozen_string_literal: true

RSpec.shared_examples 'unsubscribed brand examples' do
  # rubocop:disable RSpec/ExampleLength
  it 'sets the warning flash' do
    subject
    follow_redirect!

    expect(controller.flash[:warning]).to eq(
      <<~ALERT_MESSAGE
        You do not have an active subscription.
        To be able to use outbound Respondo features please update your subscription in <a href="#{edit_brand_path(brand)}">brand settings</a>.
      ALERT_MESSAGE
    )
  end
  # rubocop:enable RSpec/ExampleLength

  it 'redirects the user back (to root)' do
    expect(subject).to redirect_to(root_path)
  end
end
