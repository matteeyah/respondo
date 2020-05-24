# frozen_string_literal: true

module Ticketable
  extend ActiveSupport::Concern

  included do
    has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy
  end
end
