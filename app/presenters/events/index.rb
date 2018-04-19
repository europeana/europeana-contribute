# frozen_string_literal: true

module Events
  class Index < ApplicationPresenter
    include TableizedView

    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          contributions: events_content
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.events.index'))
    end

    def events_content
      {
        create: {
          url: new_event_path,
          text: t('new', scope: 'contribute.events.actions')
        },
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: events_table_head_data,
          row_data: events_table_row_data
        }
      }
    end

    def events_table_head_data
      [
        t('table.headings.event_name'),
        t('table.headings.venue'),
        t('table.headings.start_date'),
        t('table.headings.end_date'),
        t('delete', scope: 'contribute.actions')
      ]
    end

    def events_table_row_data
      @events.map do |event|
        {
          id: event.id,
          url: edit_event_path(event),
          cells: event_table_row_data_cells(event)
        }
      end
    end

    def event_table_row_data_cells(event)
      [
        table_cell(event.skos_prefLabel),
        table_cell(event.edm_happenedAt&.skos_prefLabel),
        table_cell(event.edm_occurredAt&.edm_begin),
        table_cell(event.edm_occurredAt&.edm_end),
        table_cell(event_delete_cell(event), row_link: false)
      ]
    end

    def event_delete_cell(event)
      if event.destroyable?
        view.link_to(t('delete', scope: 'contribute.actions'), delete_event_path(event))
      else
        '✘'
      end
    end
  end
end
