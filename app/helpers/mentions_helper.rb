# frozen_string_literal: true

module MentionsHelper
  def mention_author_header(mention)
    author_link = link_to("@#{mention.author.username}", mention.author.external_link, class: "text-decoration-none")
    if mention.creator
      "#{mention.creator.name} as #{author_link}"
    else
      author_link
    end
  end
end
