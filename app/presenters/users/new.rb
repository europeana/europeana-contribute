# frozen_string_literal: true

module Users
  class New < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading
        }
      end
    end

    def page_content_heading
      t('title')
    end

    def form
      @view.render partial: 'form'
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.users.new'))
    end
  end
end
