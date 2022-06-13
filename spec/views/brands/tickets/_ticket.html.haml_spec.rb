# frozen_string_literal: true

RSpec.describe 'brands/tickets/_ticket', type: :view do
  subject(:render_ticket_partial) do
    render partial: 'brands/tickets/ticket', locals: {
      brand:, ticket:
    }
  end

  let(:brand) { create(:brand) }
  let(:user) { create(:user) }
  let(:ticket) { create(:internal_ticket, brand:, status: :open).base_ticket }
  let(:policy_double) { double }
  let!(:internal_notes) { create_list(:internal_note, 2, ticket:) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:policy).and_return(policy_double)
    end

    allow(policy_double).to receive_messages(
      refresh?: true, user_in_brand?: true,
      reply?: true, internal_note?: true, invert_status?: true,
      subscription?: false
    )
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

    expect(rendered).to have_text("#{internal_notes.first.creator.name}:").and have_text(internal_notes.first.content)
      .and have_text("#{internal_notes.second.creator.name}:").and have_text(internal_notes.second.content)
  end

  context 'when ticket has creator' do
    before do
      ticket.update!(creator: user)
    end

    it 'displays creator along with author' do
      render_ticket_partial

      expect(rendered).to(
        have_text("#{ticket.creator.name} as #{ticket.author.username} - ").and(have_text(ticket.content))
      )
    end
  end

  context 'when brand has subscription' do
    before do
      allow(policy_double).to receive(:subscription?).and_return(true)
    end

    it 'displays the form toggle buttons' do
      render_ticket_partial

      expect(rendered).to have_button("toggle-reply-#{ticket.id}", count: 1)
        .and have_button("toggle-internal-note-#{ticket.id}", count: 1)
    end

    it 'displays response form' do
      render_ticket_partial

      expect(rendered).to have_field(:response_text, count: 1,
                                                     visible: :hidden).and have_button('Reply', count: 1,
                                                                                                visible: :hidden)
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
      let(:ticket) { create(:external_ticket, brand:, status: :open).base_ticket }

      before do
        ticket.external_ticket.response_url = 'https://google.com'
      end

      it 'shows external provider for ticket' do
        render_ticket_partial

        expect(rendered).to have_text(' - external - ', count: 1)
      end

      context 'when ticket has custom external provider' do
        before do
          ticket.external_ticket.custom_provider = 'hacker_news'
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
