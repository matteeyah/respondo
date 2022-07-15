# frozen_string_literal: true

require './spec/support/sign_in_out_request_helpers'
require './spec/support/unauthorized_user_examples'

RSpec.describe Brands::TicketsController, type: :request do
  include SignInOutRequestHelpers

  let(:brand) { create(:brand) }

  describe 'GET index' do
    subject(:get_index) { get "/brands/#{brand.id}/tickets", params: { status: ticket_status, query: } }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        context 'without search' do
          let(:query) { nil }

          context 'when pagination is not required' do
            let!(:open_ticket) { create(:internal_ticket, status: :open, brand:).base_ticket }
            let!(:solved_ticket) { create(:internal_ticket, status: :solved, brand:).base_ticket }

            context 'when status parameter is not specified' do
              let(:ticket_status) { nil }

              it 'renders open tickets' do
                get_index

                expect(response.body).to include(open_ticket.content)
              end
            end

            context 'when status parameter is empty string' do
              let(:ticket_status) { '' }

              it 'renders open tickets' do
                get_index

                expect(response.body).to include(open_ticket.content)
              end
            end

            context 'when status parameter is open' do
              let(:ticket_status) { 'open' }

              it 'renders open tickets' do
                get_index

                expect(response.body).to include(open_ticket.content)
              end
            end

            context 'when status parameter is solved' do
              let(:ticket_status) { 'solved' }

              it 'renders solved tickets' do
                get_index

                expect(response.body).to include(solved_ticket.content)
              end
            end
          end

          context 'when pagination is required' do
            let(:ticket_status) { nil }
            let!(:open_tickets) { create_list(:internal_ticket, 21, status: :open, brand:).map(&:base_ticket) }

            it 'paginates tickets' do
              get_index

              expect(response.body).to include(*open_tickets.first(20).map(&:content))
            end

            it 'does not show page two tickets' do
              get_index

              expect(response.body).not_to include(open_tickets.last.content)
            end
          end
        end

        context 'when searching by author name' do
          let(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }
          let(:ticket_status) { nil }
          let(:query) { tickets.first.author.username }

          it 'shows matching tickets' do
            get_index

            expect(response.body).to include(tickets.first.content)
          end

          it 'does not show other tickets' do
            get_index

            expect(response.body).not_to include(tickets.second.content)
          end
        end

        context 'when searching by ticket content' do
          let(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }
          let(:ticket_status) { nil }
          let(:query) { tickets.first.content }

          it 'shows matching tickets' do
            get_index

            expect(response.body).to include(tickets.first.content)
          end

          it 'does not show other tickets' do
            get_index

            expect(response.body).not_to include(tickets.second.content)
          end
        end
      end

      context 'when user is not authorized' do
        let(:query) { '' }
        let(:ticket_status) { nil }

        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      let(:query) { '' }
      let(:ticket_status) { nil }

      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end

  describe 'GET show' do
    subject(:get_show) { get "/brands/#{brand.id}/tickets/#{ticket.id}" }

    let!(:ticket) { create(:internal_ticket, provider: 'twitter', brand:).base_ticket }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        it 'shows the ticket' do
          get_show

          expect(response.body).to include(ticket.content)
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end

  describe 'PATCH update' do
    subject(:patch_update) { patch "/brands/#{brand.id}/tickets/#{ticket.id}", params: { ticket: { status: status } } }

    let(:ticket) { create(:internal_ticket, brand:).base_ticket }
    let(:status) { 'solved' }

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          user.update!(brand:)
        end

        it 'solves the ticket' do
          expect { patch_update }.to change { ticket.reload.status }.from('open').to('solved')
        end

        it 'redirects to brand tickets path' do
          patch_update

          expect(response).to redirect_to(brand_tickets_path(brand, status: 'open'))
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end

  describe 'POST refresh' do
    subject(:post_refresh) { post "/brands/#{brand.id}/tickets/refresh" }

    let(:load_new_tickets_job_class) { class_spy(LoadNewTicketsJob) }

    before do
      stub_const(LoadNewTicketsJob.to_s, load_new_tickets_job_class)
    end

    context 'when user is signed in' do
      let(:user) { create(:user, :with_account) }

      before do
        sign_in(user)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        it 'calls the background worker' do
          post_refresh

          expect(load_new_tickets_job_class).to have_received(:perform_later)
        end

        it 'redirects to brand tickets path' do
          post_refresh

          expect(response).to redirect_to(brand_tickets_path(brand))
        end
      end

      context 'when user is not authorized' do
        include_examples 'unauthorized user examples', 'You are not authorized.'
      end
    end

    context 'when user is not signed in' do
      include_examples 'unauthorized user examples', 'You are not signed in.'
    end
  end
end
