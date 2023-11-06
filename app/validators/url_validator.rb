# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, (options[:message] || 'must be a valid URL')) unless url_valid?(value)
  end

  def url_valid?(url)
    url = begin
      URI.parse(url)
    rescue StandardError
      false
    end
    !url || url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end
end
