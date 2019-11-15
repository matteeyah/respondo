# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) do
    render partial: 'brands/tickets/tickets', locals: {
      brand: brand, tickets: tickets
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }
  let!(:comments) { FactoryBot.create_list(:comment, 2, ticket: ticket) }
  let(:tickets) { { ticket => { nested_ticket => {} } } }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(FactoryBot.build(:user))
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

      expect(rendered).to have_text("#{ticket.author.username}:").and have_text(ticket.content)
        .and have_text("#{nested_ticket.author.username}:").and have_text(nested_ticket.content)
    end

    it 'displays response forms' do
      render_tickets_partial

      expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
    end

    it 'displays the status buttons' do
      render_tickets_partial

      expect(rendered).to have_button('Open').and have_button('Solve')
    end

    it 'displays comment form' do
      render_tickets_partial

      expect(rendered).to have_field(:comment_text)
    end

    it 'displays comments' do
      render_tickets_partial

      expect(rendered).to have_text("#{comments.first.user.name}:").and have_text(comments.first.content)
        .and have_text("#{comments.second.user.name}:").and have_text(comments.second.content)
    end
  end

  context 'when user is not authorized' do
    context 'when user does not have account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(false)
      end

      it 'displays the tickets' do
        render_tickets_partial

        expect(rendered).to have_text("#{ticket.author.username}:").and have_text(ticket.content)
          .and have_text("#{nested_ticket.author.username}:").and have_text(nested_ticket.content)
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

      it 'does not display comment form' do
        render_tickets_partial

        expect(rendered).not_to have_field(:comment_text)
      end
    end

    context 'when user has account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(true)
      end

      it 'displays the tickets' do
        render_tickets_partial

        expect(rendered).to have_text("#{ticket.author.username}:").and have_text(ticket.content)
          .and have_text("#{nested_ticket.author.username}:").and have_text(nested_ticket.content)
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

      it 'does not display comment form' do
        render_tickets_partial

        expect(rendered).not_to have_field(:comment_text)
      end
    end
  end
end
