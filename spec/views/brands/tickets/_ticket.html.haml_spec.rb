# frozen_string_literal: true

RSpec.describe 'brands/tickets/_ticket', type: :view do
  subject(:render_ticket_partial) do
    render partial: 'brands/tickets/ticket', locals: {
      brand: brand, ticket: ticket
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:user) { FactoryBot.create(:user) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let!(:internal_notes) { FactoryBot.create_list(:internal_note, 2, ticket: ticket) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end

    allow(view).to receive(:user_authorized_for?).and_return(true)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
  end

  it 'displays the ticket' do
    render_ticket_partial

    expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
  end

  it 'displays provider' do
    render_ticket_partial

    expect(rendered).to have_text(" - #{ticket.provider} - ", count: 1)
  end

  it 'displays ticket permalink' do
    render_ticket_partial

    expect(rendered).to have_link(ticket.created_at.to_formatted_s(:short), href: brand_ticket_path(brand, ticket))
  end

  it 'displays internal notes' do
    render_ticket_partial

    expect(rendered).to have_text("#{internal_notes.first.user.name}:").and have_text(internal_notes.first.content)
      .and have_text("#{internal_notes.second.user.name}:").and have_text(internal_notes.second.content)
  end

  context 'when ticket has user' do
    before do
      ticket.update(user: user)
    end

    it 'displays user along with author' do
      render_ticket_partial

      expect(rendered).to have_text("#{ticket.user.name} as #{ticket.author.username} - ").and have_text(ticket.content)
    end
  end

  context 'when brand has subscription' do
    before do
      FactoryBot.create(:subscription, brand: brand)
    end

    it 'displays the form toggle buttons' do
      render_ticket_partial

      expect(rendered).to have_button("toggle-reply-#{ticket.id}", count: 1)
        .and have_button("toggle-internal-note-#{ticket.id}", count: 1)
    end

    it 'displays response form' do
      render_ticket_partial

      expect(rendered).to have_field(:response_text, count: 1, visible: :hidden).and have_button('Reply', count: 1, visible: :hidden)
    end

    it 'displays the internal note form' do
      render_ticket_partial

      expect(rendered).to have_field(:internal_note_text, count: 1, visible: :hidden)
        .and have_button('Post', count: 1, visible: :hidden)
    end

    it 'displays the status button' do
      render_ticket_partial

      within "form[action='#{brand_ticket_invert_status_path(ticket.brand, ticket)}']" do
        expect(rendered).to have_button('type="submit"')
      end
    end

    context 'when ticket is external' do
      before do
        ticket.response_url = 'https://google.com'
        ticket.external!
      end

      it 'shows external provider for ticket' do
        render_ticket_partial

        expect(rendered).to have_text(' - external - ', count: 1)
      end

      context 'when ticket has custom external provider' do
        before do
          ticket.custom_provider = 'hacker_news'
        end

        it 'shows custom external provider for ticket' do
          render_ticket_partial

          expect(rendered).to have_text(' - hacker_news - ', count: 1)
        end
      end
    end
  end

  context 'when brand does not have subscription' do
    it 'does not display the reply form toggle button' do
      render_ticket_partial

      expect(rendered).not_to have_button("toggle-reply-#{ticket.id}")
    end

    it 'does not display the internal note form toggle button' do
      render_ticket_partial

      expect(rendered).not_to have_button("toggle-internal-note-#{ticket.id}")
    end

    it 'does not display the internal note form' do
      render_ticket_partial

      expect(rendered).not_to have_field(:internal_note_text, visible: :hidden)
    end

    it 'does not display the response form' do
      render_ticket_partial

      expect(rendered).not_to have_field(:response_text, visible: :hidden)
    end

    it 'does not display the status button' do
      render_ticket_partial

      within "form[action='#{brand_ticket_invert_status_path(ticket.brand, ticket)}']" do
        expect(rendered).not_to have_button('type="submit"')
      end
    end
  end
end
