# frozen_string_literal: true

RSpec.describe Subscription, type: :model do
  subject(:subscription) { FactoryBot.create(:subscription) }

  it { is_expected.to validate_presence_of(:external_uid) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:cancel_url) }
  it { is_expected.to validate_presence_of(:update_url) }
end
