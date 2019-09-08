# frozen_string_literal: true

RSpec.describe Author, type: :model do
  it { is_expected.to have_many(:tickets) }
end
