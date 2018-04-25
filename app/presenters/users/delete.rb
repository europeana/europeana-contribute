# frozen_string_literal: true

module Users
  class Delete < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: t('title') + ' - ' + @user.email,
          confirmation_text: [
            t('delete', scope: 'contribute.form.warnings'),
            t('delete', scope: 'contribute.users.confirm')
          ]
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    def form
      @view.render partial: 'delete', locals: { user: @user }
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.users.delete'))
    end
  end
end
