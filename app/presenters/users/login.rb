# frozen_string_literal: true

module Users
  class Login < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading
        }
      end
    end

    # TODO: i18n
    def page_content_heading
      'Login'
    end

    def form
      @view.render partial: 'login_form'
    end

    protected

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end
  end
end
