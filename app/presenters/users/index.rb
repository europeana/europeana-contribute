# frozen_string_literal: true

module Users
  class Index < ApplicationPresenter
    include TableizedView

    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          resources: users_content
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.users.index'))
    end

    def users_content
      {
        create: {
          url: new_user_path,
          text: t('new', scope: 'contribute.users.actions')
        },
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: users_table_head_data,
          row_data: users_table_row_data
        }
      }
    end

    def users_table_head_data
      [
        t('table.headings.email'),
        t('table.headings.role'),
        t('table.headings.events'),
        t('table.headings.last_sign_in_at'),
        t('delete', scope: 'contribute.actions')
      ]
    end

    def users_table_row_data
      @users.map do |user|
        {
          id: user.id,
          url: edit_user_path(user),
          cells: user_table_row_data_cells(user)
        }
      end
    end

    def user_table_row_data_cells(user)
      [
        table_cell(user.email),
        table_cell(user.role),
        table_cell(user.events.map(&:name).join('; ')),
        table_cell(user.last_sign_in_at),
        table_cell(user_delete_cell(user), row_link: false)
      ]
    end

    def user_delete_cell(user)
      if user.destroyable?
        view.link_to(t('delete', scope: 'contribute.actions'), delete_user_path(user))
      else
        '✘'
      end
    end
  end
end
