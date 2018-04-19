# frozen_string_literal: true

module Events
  class Delete < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: t('title') + ' - ' + @event.name,
          confirmation_text: [
            t('delete', scope: 'contribute.form.warnings'),
            t('delete', scope: 'contribute.events.confirm')
          ]
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    def form
      @view.render partial: 'delete', locals: { event: @event }
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.events.delete'))
    end
  end
end
