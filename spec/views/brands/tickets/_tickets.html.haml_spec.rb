# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let!(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }

  subject { render partial: 'brands/tickets/tickets', locals: { tickets: [ticket] } }

  before do
    assign(:brand, brand)
  end

  it 'displays the tickets' do
    subject

    expect(rendered).to have_text "#{ticket.author.username}: #{ticket.content}"
    expect(rendered).to have_text "#{nested_ticket.author.username}: #{nested_ticket.content}"
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:authorized?).and_return(true)
    end

    it 'displays response forms' do
      subject

      expect(rendered).to have_field(:response_text, count: 2)
      expect(rendered).to have_button('Reply', count: 2)
    end

    it 'displays the status buttons' do
      expect(rendered).not_to have_button('Open')
      expect(rendered).not_to have_button('Solve')
    end
  end

  context 'when user is not authorized' do
    before do
      allow(view).to receive(:authorized?).and_return(false)
    end

    it 'does not display response forms' do
      subject

      expect(rendered).not_to have_field(:response_text)
      expect(rendered).not_to have_button('Reply')
    end

    it 'does not display the status button' do
      expect(rendered).not_to have_button('Open')
      expect(rendered).not_to have_button('Solve')
    end
  end
end
