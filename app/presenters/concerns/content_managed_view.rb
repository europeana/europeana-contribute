# frozen_string_literal: true

require 'rich_text_renderer'

module ContentManagedView
  extend ActiveSupport::Concern

  protected

  def contentful_richtext_to_html(rich_text)
    @richtext_renderer ||= RichTextRenderer::Renderer.new
    @richtext_renderer.render(rich_text)
  end
end
