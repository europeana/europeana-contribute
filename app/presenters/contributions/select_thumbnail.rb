# frozen_string_literal: true

module Contributions
  class SelectThumbnail < ApplicationPresenter
    def page_content_heading
      'Select thumbnail'
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          subtitle: page_content_subheading
        }
      end
    end

    def form
      @view.render partial: 'contributions/thumbnails', locals: { contribution: @contribution }
    end
  end
end
