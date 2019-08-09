# frozen_string_literal: true

require 'rich_text_renderer'

module ContentManagedView
  extend ActiveSupport::Concern
  include ContentfulHelper

  protected

  def contentful_richtext_to_html(rich_text)
    @richtext_renderer ||= RichTextRenderer::Renderer.new
    @richtext_renderer.render(rich_text)
  end

  def contentful_entry(content_type: 'staticPage', identifier: '/')
    contentful.entries(content_type: content_type, include: 2, 'fields.identifier' => identifier).first
  end
end
