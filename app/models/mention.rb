# frozen_string_literal: true

class Mention < ApplicationRecord
  include WithDescendants

  validates :external_uid, uniqueness: { scope: :source_id }, presence: { allow_blank: false }
  validates :external_link, presence: { allow_blank: false }, url: true
  validates :content, presence: { allow_blank: false }

  enum status: { open: 0, solved: 1 }

  scope :root, -> { where(parent: nil) }

  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :author
  belongs_to :organization
  belongs_to :parent, class_name: 'Mention', optional: true
  belongs_to :source, class_name: 'OrganizationAccount'

  has_one :assignment, dependent: :destroy

  has_many :replies, class_name: 'Mention', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  has_many :internal_notes, dependent: :destroy
  has_many :mention_tags, dependent: :destroy
  has_many :tags, through: :mention_tags

  delegate :provider, :client, to: :source

  def respond_as(user, reply)
    client_response = client.reply(reply, external_uid)
    organization.mentions.create!(
      **client_response.except(:parent_uid, :author),
      creator: user, author: Author.from_client!(client_response[:author], provider),
      parent: source.mentions.find_by(external_uid: client_response[:parent_uid]),
      source:
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
          You work at a company called #{organization.screen_name}.
          #{organization.ai_guidelines}
        AI_WORKPLACE
      },
      {
        role: 'system', content: <<~AI_POSITION
          You are a social media manager and a support representative.
          Messages from the user are social media posts where someone mentions the company that you work for.
          You respond to those posts with a message.
        AI_POSITION
      },
      { role: 'user', content: "#{author.username}: #{content}" }
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
