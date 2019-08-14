# frozen_string_literal: true

module Pages
  class Show < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          channel_info: {
            name: page_content_heading
          },
          title: page_content_heading,
          headline: page_content_heading,
          main_content_of_page: @page.fields[:main_content_of_page]
        }
      end
    end

    def include_nav_searchbar
      false
    end

    def page_content_heading
      @page.fields[:headline]
    end
  end
end
