# frozen_string_literal: true

# Helper module for contentful
# see also the contentful gem: https://github.com/contentful/contentful.rb
module ContentfulHelper
  def contentful
    @client ||= Contentful::Client.new(
      access_token: ENV['CONTENTFUL_ACCESS_TOKEN'],
      space: ENV['CONTENTFUL_SPACE_ID'],
      dynamic_entries: :auto,
      raise_errors: true
    )
  end
end
