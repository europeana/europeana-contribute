# frozen_string_literal: true

module Contributions
  class Index < ApplicationPresenter
    include TableizedView

    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          resources: contributions_content
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.contributions.index'))
    end

    def contributions_content
      {
        has_events: @events.present?,
        events: contributions_events,
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: contributions_table_head_data,
          row_data: contributions_table_row_data
        }
      }
    end

    def contributions_events
      events = @events.map do |event|
        {
          url: contributions_path(event_id: event.id),
          label: event.name,
          is_selected: @selected_event.present? && event == @selected_event
        }
      end
      events.unshift(url: contributions_path(event_id: 'none'), label: t('filters.events.none'), is_selected: @selected_event == 'none')
      events.unshift(url: contributions_path, label: '', is_selected: @selected_event.blank?)
    end

    def contributions_table_head_data
      [
        t('table.headings.name'),
        t('table.headings.title'),
        t('table.headings.ticket'),
        t('table.headings.date'),
        t('table.headings.status'),
        t('table.headings.media'),
        (@deletion_enabled ? t('delete', scope: 'contribute.actions') : nil)
      ].compact
    end

    def contributions_table_row_data
      @contributions.map do |contribution|
        {
          id: contribution[:uuid],
          url: edit_contribution_path(contribution[:uuid]),
          cells: contribution_table_row_data_cells(contribution)
        }
      end
    end

    def contribution_table_row_data_cells(contribution)
      [
        table_cell(contribution[:contributor]),
        table_cell(truncate(contribution[:title].join('; '))),
        table_cell(contribution[:identifier].join('; ')),
        table_cell(contribution[:date]),
        table_cell(t(contribution[:status], scope: 'contribute.contributions.states')),
        table_cell(contribution[:media] ? '✔' : '✘'),
        (@deletion_enabled ? table_cell(contribution_delete_cell(contribution), row_link: false) : nil)
      ].compact
    end

    def contribution_delete_cell(contribution)
      if contribution[:removable?]
        view.link_to(
          t('delete', scope: 'contribute.actions'),
          delete_contribution_path(contribution[:uuid])
        )
      else
        '✘'
      end
    end
  end
end
