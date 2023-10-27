# frozen_string_literal: true

class Ticket < ApplicationRecord
  include WithDescendants

  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: %i[ticketable_type organization_id] }
  validates :content, presence: { allow_blank: false }
  validates :external_modified_at, presence: { allow_blank: true }

  enum status: { open: 0, solved: 1 }

  delegated_type :ticketable, types: %w[InternalTicket ExternalTicket EmailTicket]
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

  accepts_nested_attributes_for :ticketable

  def respond_as(user, reply) # rubocop:disable Metrics/AbcSize
    client_response = client.reply(reply, external_uid)

    organization.tickets.create!(
      **client_response.except(:parent_uid, :author),
      creator: user, ticketable_type:,
      parent: source.tickets.find_by(ticketable_type:, external_uid: client_response[:parent_uid]),
      author: Author.from_client!(client_response[:author], provider),
      ticketable_attributes: client_response[:ticketable_attributes] || { source: }
    )
  rescue Twitter::Error
    false
  end
end
