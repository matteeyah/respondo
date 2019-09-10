# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:tickets) { FactoryBot.create_list(:ticket, 2, brand: brand) }

  subject { render partial: 'brands/tickets/tickets', locals: { tickets: tickets } }

  before do
    assign(:brand, brand)
  end

  it 'displays all the tickets' do
    subject

    expect(rendered).to have_text "#{tickets.first.author.username}: #{tickets.first.content}"
    expect(rendered).to have_text "#{tickets.second.author.username}: #{tickets.second.content}"
  end

  context 'with nested tickets' do
    let(:nested_tickets) { FactoryBot.create_list(:ticket, 2, brand: brand, parent: tickets.first) }

    it 'renders the partial recursively' do
      subject

      expect(rendered).to render_template(partial: 'brands/tickets/_tickets')
    end
  end

  context 'when user is authorized' do
    before do
      assign(:user_brand, brand)
    end

    it 'displays response forms' do
      subject

      expect(rendered).to have_field(:response_text, count: 2)
      expect(rendered).to have_button('Reply', count: 2)
    end
  end

  context 'when user is not authorized' do
    it 'does not display response forms' do
      subject

      expect(rendered).not_to have_field(:response_text)
      expect(rendered).not_to have_button('Reply')
    end
  end
end
