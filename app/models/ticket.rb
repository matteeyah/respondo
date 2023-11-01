# frozen_string_literal: true

class Ticket < ApplicationRecord
  include WithDescendants

  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: %i[ticketable_type organization_id] }
  validates :content, presence: { allow_blank: false }

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
  rescue X::Error
    false
  end

  def generate_ai_response(prompt = nil)
    OpenAI::Client.new.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: ai_messages(prompt), temperature: 0.7
      }
    ).dig('choices', 0, 'message', 'content').chomp.strip
  end

  private

  def ai_messages(prompt) # rubocop:disable Metrics/MethodLength
    [
      {
        role: 'system', content: <<~AI_WORKPLACE
          You work at a company called #{ticket.organization.screen_name}.
          #{ticket.organization.ai_guidelines}
        AI_WORKPLACE
      },
      {
        role: 'system', content: <<~AI_POSITION
          You are a social media manager and a support representative.
          Messages from the user are social media posts where someone mentions the company that you work for.
          You respond to those posts with a message.
        AI_POSITION
      },
      { role: 'user', content: "#{ticket.author.username}: #{ticket.content}" }
    ].tap do |messages|
      if prompt != 'true'
        messages.insert(
          2,
          { role: 'system', content: "Generate a response using this prompt: #{prompt}" }
        )
      end
    end
  end
end
