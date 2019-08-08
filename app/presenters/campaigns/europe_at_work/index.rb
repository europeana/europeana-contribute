# frozen_string_literal: true

require 'rich_text_renderer'

module Campaigns
  module EuropeAtWork
    class Index < ApplicationPresenter
      include ContentfulHelper
      def content
        mustache[:content] ||= begin
          {
            channel_info: {
              name: page_content_heading
            },
            title: page_content_heading,
            headline: page_content_heading,
            main_content_of_page: contentful_html
          }
        end
      end

      def include_nav_searchbar
        false
      end

      def page_content_heading
        t('title')
      end

      def contentful_html
        renderer = RichTextRenderer::Renderer.new
        #return contentful_entry.fields[:main_content_of_page]
        renderer.render(contentful_entry.fields[:main_content_of_page])
      end
      protected

      def t(*args, **options)
        I18n.t(*args, options.reverse_merge(scope: 'contribute.campaigns.europe-at-work.pages.index'))
      end

      def contentful_entry
        contentful.entries(content_type: 'staticPage', include: 2, 'fields.identifier' => 'europe-at-work').first
      end
    end
  end
end
