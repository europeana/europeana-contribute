# frozen_string_literal: true

module HerofiedView
  extend ActiveSupport::Concern

  def content
    mustache[:content] ||= begin
      {
        title: page_content_heading,
        subtitle: page_content_subheading,
        hero: {
          url: page_hero_url
        }
      }
    end
  end
end
