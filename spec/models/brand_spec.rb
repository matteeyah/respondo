# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  it { is_expected.to have_many(:users) }

  describe '.from_omniauth' do
    let(:auth_hash) { JSON.parse(file_fixture('twitter_brand_oauth_hash.json').read, object_class: OpenStruct) }

    subject { Brand.from_omniauth(auth_hash) }

    context 'when there is no matching brand' do
      it 'creates a brand' do
        expect { subject }.to change { Brand.count }.from(0).to(1)
        expect(subject).to be_persisted
        expect(subject).to have_attributes(external_uid: auth_hash.uid, nickname: auth_hash.info.nickname)
      end
    end

    context 'when there is a matching brand' do
      let!(:brand) { FactoryBot.create(:brand, external_uid: auth_hash.uid) }

      it 'returns the matching brand' do
        expect(subject).to eq(brand)
      end
    end
  end
end
