# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          subtitle: t('contribute.campaigns.migration.pages.new.subtitle'),
          hero: {
            url: asset_path('ugc-form-header.jpg')
          }
        }
      end
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
