# frozen_string_literal: true

module Campaigns
  module EuropeAtWork
    class Index < ApplicationPresenter
      include ContentManagedView

      def content
        mustache[:content] ||= begin
          {
            channel_info: {
              name: page_content_heading
            },
            title: page_content_heading,
            headline: page_content_heading,
            main_content_of_page: contentful_richtext_to_html(static_page.fields[:main_content_of_page])
          }
        end
      end

      def include_nav_searchbar
        false
      end

      def page_content_heading
        static_page.fields[:headline]
      end

      protected

      def static_page
        @static_page ||= contentful_entry(identifier: 'europe-at-work')
      end

      def t(*args, **options)
        I18n.t(*args, options.reverse_merge(scope: 'contribute.campaigns.europe-at-work.pages.index'))
      end
    end
  end
end
