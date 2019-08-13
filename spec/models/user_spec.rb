# frozen_string_literal: true

RSpec.describe User, type: :model do
  it { is_expected.to belong_to(:brand).optional }

  describe '.from_omniauth' do
    let(:auth_hash) { JSON.parse(file_fixture('google_user_oauth_hash.json').read, object_class: OpenStruct) }

    subject { User.from_omniauth(auth_hash) }

    context 'when there is no matching user' do
      it 'creates a user' do
        expect { subject }.to change { User.count }.from(0).to(1)
        expect(subject).to be_persisted
        expect(subject).to have_attributes(external_uid: auth_hash.uid, email: auth_hash.info.email, name: auth_hash.info.name)
      end
    end

    context 'when there is a matching user' do
      let!(:user) { FactoryBot.create(:user, external_uid: auth_hash.uid) }

      it 'returns the matching user' do
        expect(subject).to eq(user)
      end
    end
  end
end
