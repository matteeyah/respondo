# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  it { is_expected.to belong_to(:brand) }
end
