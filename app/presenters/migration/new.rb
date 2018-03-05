# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          subtitle: t('contribute.campaigns.migration.pages.new.subtitle'),
          hero: {
            url: 'https://europeana-portal-production.s3.amazonaws.com/media_objects/000/001/744/files/94235082efaf0b297ef4cc4f377fd8ed.original.jpg?1509521460'
          }
        }
      end
    end

    def debug
      @story.errors.full_messages
    end

    def page_content_heading
      t('contribute.campaigns.migration.pages.new.title')
    end

    def form
      @view.render partial: 'form'
    end

    protected

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end
  end
end
