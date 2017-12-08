# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          text: errors + aggregation_form
        }
      end
    end

    def page_content_heading
      'Tell your story'
    end

    protected

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end

    def aggregation_form
      @view.render partial: 'aggregation_form'
    end
  end
end
