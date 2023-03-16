# frozen_string_literal: true

class Ticket < ApplicationRecord
  include FromOmniauth
  include WithDescendants

  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: %i[ticketable_type organization_id] }
  validates :content, presence: { allow_blank: false }

  enum status: { open: 0, solved: 1 }

  delegated_type :ticketable, types: %w[InternalTicket ExternalTicket]
  delegate :provider, :source, :client, to: :ticketable

  acts_as_taggable_on :tags

  scope :root, -> { where(parent: nil) }

  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :author
  belongs_to :organization
  belongs_to :parent, class_name: 'Ticket', optional: true

  has_one :assignment, dependent: :destroy

  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  has_many :internal_notes, dependent: :destroy

  def respond_as(user, reply)
    client_response = client.reply(reply, external_uid)
    Ticket.from_client_response!(provider, client_response, source, user)
  rescue Twitter::Error
    false
  end
end
