# frozen_string_literal: true

RSpec.describe SubscriptionsController, type: :request do
  describe 'POST create' do
    subject(:post_create) do
      post '/subscriptions.json',
           params: webhook_params,
           as: :json
    end

    let(:brand) { FactoryBot.create(:brand) }

    let(:default_params) do
      {
        subscription_id: 1,
        status: 'active',
        email: 'text@example.com',
        update_url: 'https://example.com/update',
        cancel_url: 'https://example.com/cancel',
        passthrough: "{ \"brand_id\": #{brand.id} }"
      }
    end

    context 'when subscription is created' do
      let(:webhook_params) { default_params }

      it 'creates a subscription' do
        expect { post_create }.to change(Subscription, :count).from(0).to(1)
      end
    end

    context 'when subscription is updated' do
      let(:subscription) { FactoryBot.create(:subscription, brand: brand) }
      let(:webhook_params) { default_params.merge(subscription_id: subscription.external_uid) }

      it 'updates the subscription' do
        expect { post_create }.to change { subscription.reload.update_url }.to('https://example.com/update')
      end
    end

    context 'when subscription is cancelled' do
      let(:subscription) { FactoryBot.create(:subscription, brand: brand) }
      let(:webhook_params) { default_params.merge(subscription_id: subscription.external_uid, status: 'deleted') }

      it 'changes the subscription status to deleted' do
        expect { post_create }.to change { subscription.reload.status }.from('active').to('deleted')
      end
    end
  end
end
