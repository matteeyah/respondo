# frozen_string_literal: true

RSpec.shared_examples 'accountable' do
  describe 'Validations' do
    subject(:account) { create(described_class.to_s.underscore) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email).allow_nil }
  end
end
