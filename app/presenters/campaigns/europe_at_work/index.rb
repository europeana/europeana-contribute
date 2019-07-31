# frozen_string_literal: true

module Campaigns
  module EuropeAtWork
    class Index < ApplicationPresenter
      include ContentfulHelper
      def content
        mustache[:content] ||= begin
          {
            contentful_static: contentful_entry.fields.inspect
          }
        end
      end

      def contentful_entry
        contentful.entries(content_type: 'staticPage',  include: 2, "fields.identifier" => 'europe-at-work').first
      end
    end
  end
end
