# frozen_string_literal: true

RSpec.describe Subscription, type: :model do
  subject(:subscription) { FactoryBot.create(:subscription) }

  it { is_expected.to validate_presence_of(:external_uid) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:cancel_url) }
  it { is_expected.to validate_presence_of(:update_url) }

  describe '#change_quantity' do
    subject(:change_quantity) { subscription.change_quantity(1000) }

    let(:paddle_client_double) { instance_spy(Paddle::Client) }

    before do
      paddle_client_spy = class_spy(Paddle::Client, new: paddle_client_double)
      stub_const('Paddle::Client', paddle_client_spy)
    end

    it 'calls underlying paddle client method' do
      change_quantity

      expect(paddle_client_double).to have_received(:change_quantity).with(subscription.external_uid, 1000)
    end
  end
end
