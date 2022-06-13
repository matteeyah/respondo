# frozen_string_literal: true

RSpec.describe Brands::ExternalTicketsController, type: :request do
  let(:brand) { create(:brand) }
  let(:user) { create(:user) }

  describe 'POST create.json' do
    subject(:post_create_json) do
      post "/brands/#{brand.id}/external_tickets.json",
           params: external_json.merge(personal_access_token: personal_access_token_json),
           as: :json
    end

    let(:external_json) do
      {
        external_uid: '123hello321world',
        content: 'This is content from the external ticket example.',
        parent_uid: 'external_ticket_parent_external_uid',
        response_url: 'https://response_url.com',
        author: {
          external_uid: 'external_ticket_author_external_uid',
          username: 'best_username'
        },
        created_at: 1.day.ago.utc
      }
    end

    context 'when token is authorized' do
      let(:token) { '123hello321world' }
      let(:personal_access_token_json) { { name: 'something_nice', token: } }

      before do
        create(:personal_access_token, name: 'something_nice', token:, user:)
      end

      context 'when user is authorized' do
        before do
          brand.users << user
        end

        context 'when payload is valid' do
          it 'creates a ticket' do
            expect { post_create_json }.to change(Ticket, :count).from(0).to(1)
          end

          it 'creates a ticket with matching attributes' do
            post_create_json

            expect(Ticket.find_by(external_uid: external_json[:external_uid])).to(
              have_attributes(content: external_json[:content])
            )
          end

          it 'renders json' do
            post_create_json

            expect(response.content_type).to eq('application/json; charset=utf-8')
          end

          it 'renders new ticket' do
            post_create_json

            expect(response.body).to eq(Ticket.find_by(external_uid: external_json[:external_uid]).to_json)
          end
        end

        context 'when payload is invalid' do
          let(:external_json) do
            {
              external_uid: '123hello321world',
              content: 'This is content from the external ticket example.',
              parent_uid: 'external_ticket_parent_external_uid',
              author: {
                external_uid: 'external_ticket_author_external_uid',
                username: 'best_username'
              }
            }
          end

          it 'does not create a ticket' do
            expect { post_create_json }.not_to change(Ticket, :count).from(0)
          end

          it 'renders error json' do
            post_create_json

            expect(response.body).to eq({ error: 'Invalid payload schema.' }.to_json)
          end
        end
      end

      context 'when user is not authorized' do
        it 'returns a forbidden response' do
          post_create_json

          expect(response).to have_http_status(:forbidden)
        end

        it 'renders an error message' do
          post_create_json

          expect(response.body).to eq(JSON.dump(error: 'not authorized'))
        end
      end
    end

    context 'when token is not authorized' do
      let(:personal_access_token_json) { { name: 'something_nice', token: 'bogus' } }

      before do
        create(:personal_access_token, name: 'something_nice', user:)
      end

      it 'returns a forbidden response' do
        post_create_json

        expect(response).to have_http_status(:forbidden)
      end

      it 'renders an error message' do
        post_create_json

        expect(response.body).to eq(JSON.dump(error: 'not authorized'))
      end
    end

    context 'when token does not exist' do
      let(:personal_access_token_json) { { name: 'something_bad', token: 'bogus' } }

      it 'returns a forbidden response' do
        post_create_json

        expect(response).to have_http_status(:forbidden)
      end

      it 'renders an error message' do
        post_create_json

        expect(response.body).to eq(JSON.dump(error: 'not authorized'))
      end
    end
  end
end
