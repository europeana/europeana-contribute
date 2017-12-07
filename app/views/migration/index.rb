# frozen_string_literal: true

module Migration
  class Index < ApplicationView
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          text: text
        }
      end
    end

    def text
      notice = flash[:notice].present? ? "<p><strong>#{flash[:notice]}</strong></p>" : ''
      link = link_to('Tell your story...', new_migration_path, class: 'btn btn-light pill')
      notice + call_to_action + link
    end

    def call_to_action
      '<p>We invite you to contribute stories relating to European migration in your family history.</p>'
    end

    def page_content_heading
      'Migration'
    end
  end
end
