# frozen_string_literal: true

module Migration
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading
        }
      end
    end

    def flash_notice
      flash[:notice]
    end

    def begin_link
      {
        url: new_migration_path,
        text: 'Tell your story...'
      }
    end

    def call_to_action
      'We invite you to contribute stories relating to European migration in your family history.'
    end

    def page_content_heading
      'Migration'
    end
  end
end
