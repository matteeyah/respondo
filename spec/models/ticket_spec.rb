# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  it { is_expected.to belong_to(:author) }
  it { is_expected.to belong_to(:brand) }
  it { is_expected.to belong_to(:parent).optional }
  it { is_expected.to have_many(:replies) }
end
