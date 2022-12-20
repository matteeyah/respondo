# frozen_string_literal: true

module Brands
  class ExternalTicketsController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    before_action :authorize_token!

    def create
      respond_to do |format|
        format.json do
          if validate_json_payload
            new_ticket = Ticket.from_external_ticket!(create_params, brand, nil)
            render json: new_ticket
          else
            render json: { error: 'Invalid payload schema.' }
          end
        end
      end
    end

    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end

    def validate_json_payload
      schema = Rails.root.join('lib/external_ticket_json_schema.json').read
      JSON::Validator.validate(schema, request.raw_post)
    end

    def create_params
      params.permit(
        :external_uid, :content, :parent_uid, :response_url, :custom_provider,
        author: %i[external_uid username]
      )
    end

    def token_params
      params.require(:personal_access_token).permit(:name, :token)
    end

    def token
      PersonalAccessToken.find_by(name: token_params[:name])
    end

    def authorize_token!
      return if token&.authenticate_token(token_params[:token]) && token.user.brand == brand

      render status: :forbidden, json: { error: 'not authorized' }
    end
  end
end
