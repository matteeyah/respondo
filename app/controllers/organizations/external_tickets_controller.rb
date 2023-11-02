# frozen_string_literal: true

module Organizations
  class ExternalTicketsController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    before_action :set_organization, only: :create
    before_action :authorize_token!

    def create
      respond_to do |format|
        format.json do
          if validate_json_payload
            new_ticket = @organization.tickets.create!(create_params)
            render json: new_ticket
          else
            render json: { error: 'Invalid payload schema.' }
          end
        end
      end
    end

    private

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def validate_json_payload
      schema = Rails.root.join('lib/external_ticket_json_schema.json').read
      JSON::Validator.validate(schema, request.raw_post)
    end

    def ticket_params
      params.permit(
        :external_uid, :content, :external_link,
        author: %i[external_uid username],
        ticketable_attributes: %i[response_url custom_provider]
      )
    end

    def token_params
      params.require(:personal_access_token).permit(:name, :token)
    end

    def author_params
      params.require(:author).permit(:external_uid, :username, :external_link)
    end

    def token
      PersonalAccessToken.find_by(name: token_params[:name])
    end

    def authorize_token!
      return if token&.authenticate_token(token_params[:token]) && token.user.organization == @organization

      render status: :forbidden, json: { error: 'not authorized' }
    end

    def parent
      @organization.tickets.find_by(ticketable_type: 'ExternalTicket', external_uid: params[:parent_uid])
    end

    def author
      Author.from_client!(author_params, :external)
    end

    def create_params
      ticket_params.merge(author:, parent:, ticketable_type: 'ExternalTicket')
    end
  end
end
