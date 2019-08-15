# frozen_string_literal: true

module Pages
  class Show < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
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
