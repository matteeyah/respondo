# frozen_string_literal: true

class Mention < ApplicationRecord
  include WithDescendants

  validates :external_uid, uniqueness: { scope: :source_id }, presence: { allow_blank: false }
  validates :external_link, presence: { allow_blank: false }, url: true
  validates :content, presence: { allow_blank: false }

  enum :status, { open: 0, solved: 1 }

  scope :root, -> { where(parent: nil) }

  belongs_to :creator, class_name: "User", optional: true
  belongs_to :author
  belongs_to :organization
  belongs_to :parent, class_name: "Mention", optional: true
  belongs_to :source, class_name: "OrganizationAccount"

  has_one :assignment, dependent: :destroy

  has_many :replies, class_name: "Mention", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  has_many :internal_notes, dependent: :destroy
  has_many :mention_tags, dependent: :destroy
  has_many :tags, through: :mention_tags

  delegate :provider, :client, to: :source

  def respond_as(user, reply)
    client_response = client.reply(reply, external_uid)
    organization.mentions.create!(
      **client_response.except(:parent_uid, :author),
      creator: user, author: Author.from_client!(client_response[:author], provider, organization),
      parent: source.mentions.find_by(external_uid: client_response[:parent_uid]),
      source:
    )
  rescue X::Error
    false
  end

  def generate_ai_response(prompt = nil)
    OpenAI::Client.new.responses.create(
      parameters: {
        model: "gpt-4o",
        instructions: ai_instructions(prompt),
        input: "#{author.username}: #{content}"
      }
    ).dig("choices", 0, "message", "content").chomp.strip
  end

  private

  def ai_instructions(prompt)
    instructions = <<~INSTRUCTIONS
      You work at a company called #{organization.screen_name}.

      #{organization.ai_guidelines}

      You are a social media manager and a support representative.
      Messages from the user are social media posts where someone mentions the company that you work for.

      You respond to those posts with a message.
    INSTRUCTIONS

    instructions.tap do |instr|
      instr << "Generate a response using this prompt: #{prompt}" if prompt != "true"
    end
  end
end
