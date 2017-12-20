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
        text: t('begin_link')
      }
    end

    def call_to_action
      t('call_to_action')
    end

    def page_content_heading
      t('title')
    end

    protected

    def t(*args, **options)
      I18n.t(*args, options.reverse_merge(scope: 'site.campaigns.migration.pages.index'))
    end
  end
end
