# frozen_string_literal: true

# Helper module for contentful
# see also the contentful gem: https://github.com/contentful/contentful.rb
module ContentfulHelper
  def contentful
    @contentful_client ||= Contentful::Client.new(
      access_token: Rails.application.config.x.contentful.access_token,
      space: Rails.application.config.x.contentful.space,
      dynamic_entries: :auto,
      raise_errors: true
    )
  end

  def contentful_entry(content_type: 'staticPage', identifier: '/')
    contentful.entries(content_type: content_type, include: 2, 'fields.identifier' => identifier).first
  end
end
