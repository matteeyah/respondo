# frozen_string_literal: true

RSpec.describe LoadTicketsJob, type: :job do
  let(:brand) { FactoryBot.create(:brand) }
  let(:mentions) { [double('Mention#1'), double('Mention#2')] }

  before do
    allow(Brand).to receive(:find_by).with(id: brand.id).and_return(brand)
    allow(brand).to receive(:new_mentions).and_return(mentions)
  end

  subject { described_class.perform_now(brand.id) }

  it 'creates tickets' do
    expect(Ticket).to receive(:from_tweet).with(anything, brand).exactly(2).times

    subject
  end
end
