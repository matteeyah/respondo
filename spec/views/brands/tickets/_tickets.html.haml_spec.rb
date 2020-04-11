# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) do
    render partial: 'brands/tickets/tickets', locals: {
      brand: brand, tickets: tickets
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:user) { FactoryBot.create(:user) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }
  let!(:internal_notes) { FactoryBot.create_list(:internal_note, 2, ticket: ticket) }
  let(:tickets) { { ticket => { nested_ticket => {} } } }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end

    allow(view).to receive(:user_authorized_for?).and_return(false)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:user_authorized_for?).and_return(true)
    end

    it 'displays the tickets' do
      render_tickets_partial

      expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
        .and have_text("#{nested_ticket.author.username} - ").and have_text(nested_ticket.content)
    end

    it 'displays provider for root tickets' do
      render_tickets_partial

      expect(rendered).to have_text(" - #{ticket.provider} - ", count: 1)
    end

    it 'displays response forms' do
      render_tickets_partial

      expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
    end

    it 'displays the status buttons' do
      render_tickets_partial

      expect(rendered).to have_button('Open').and have_button('Solve')
    end

    it 'displays internal note forms' do
      render_tickets_partial

      expect(rendered).to have_field(:internal_note_text, count: 2).and have_button('Post Internal Note', count: 2)
    end

    it 'displays internal notes' do
      render_tickets_partial

      expect(rendered).to have_text("#{internal_notes.first.user.name}:").and have_text(internal_notes.first.content)
        .and have_text("#{internal_notes.second.user.name}:").and have_text(internal_notes.second.content)
    end

    context 'when ticket is external' do
      before do
        ticket.response_url = nested_ticket.response_url = 'https://google.com'
        ticket.external!
        nested_ticket.external!
      end

      it 'displays response form' do
        render_tickets_partial

        expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
      end

      it 'shows external provider for root tickets' do
        render_tickets_partial

        expect(rendered).to have_text(' - external - ', count: 1)
      end

      context 'when tickets have external provider' do
        before do
          ticket.custom_provider = nested_ticket.custom_provider = 'hacker_news'
        end

        it 'shows custom external provider for root tickets' do
          render_tickets_partial

          expect(rendered).to have_text(' - hacker_news - ', count: 1)
        end
      end
    end

    context 'when ticket has user' do
      before do
        ticket.update(user: user)
      end

      it 'displays user along with author' do
        render_tickets_partial

        expect(rendered).to have_text("#{ticket.user.name} as #{ticket.author.username} - ").and have_text(ticket.content)
      end
    end
  end

  context 'when user is not authorized' do
    context 'when user does not have account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(false)
      end

      it 'displays the tickets' do
        render_tickets_partial

        expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
          .and have_text("#{nested_ticket.author.username} - ").and have_text(nested_ticket.content)
      end

      it 'displays provider for root tickets' do
        render_tickets_partial

        expect(rendered).to have_text(" - #{ticket.provider} - ", count: 1)
      end

      it 'does not display response textbox' do
        render_tickets_partial

        expect(rendered).not_to have_field(:response_text)
      end

      it 'does not display response button' do
        render_tickets_partial

        expect(rendered).not_to have_button('Reply')
      end

      it 'does not display open buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
      end

      it 'does not display solve buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Solve')
      end

      it 'does not display internal note form' do
        render_tickets_partial

        expect(rendered).not_to have_field(:internal_note_text)
      end
    end

    context 'when user has account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(true)
      end

      it 'displays the tickets' do
        render_tickets_partial

        expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
          .and have_text("#{nested_ticket.author.username} - ").and have_text(nested_ticket.content)
      end

      it 'displays response forms' do
        render_tickets_partial

        expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
      end

      it 'does not display open buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
      end

      it 'does not display solve buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Solve')
      end

      it 'does not display internal note form' do
        render_tickets_partial

        expect(rendered).not_to have_field(:internal_note_text)
      end

      context 'when ticket is external' do
        before do
          ticket.response_url = nested_ticket.response_url = 'https://google.com'
          ticket.external!
          nested_ticket.external!
        end

        it 'does not display response form' do
          render_tickets_partial

          expect(rendered).not_to have_button('Reply')
        end

        it 'shows external provider for root tickets' do
          render_tickets_partial

          expect(rendered).to have_text(' - external - ', count: 1)
        end

        context 'when tickets have external provider' do
          before do
            ticket.custom_provider = nested_ticket.custom_provider = 'hacker_news'
          end

          it 'shows custom external provider for root tickets' do
            render_tickets_partial

            expect(rendered).to have_text(' - hacker_news - ', count: 1)
          end
        end
      end

      context 'when ticket has user' do
        before do
          ticket.update(user: user)
        end

        it 'does not display user' do
          render_tickets_partial

          expect(rendered).not_to have_text("#{ticket.user.name} as #{ticket.author.username}:")
        end
      end
    end
  end
end
