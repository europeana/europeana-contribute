# frozen_string_literal: true

module Events
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          contributions: events_content
        }
      end
    end

    def page_content_heading
      # t(:title)
      'Collection day events'
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.events.index'))
    end

    def events_content
      {
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: events_table_head_data,
          row_data: events_table_row_data
        }
      }
    end

    def events_table_head_data
      [
        'Event name',
        'Venue',
        'Start date',
        'End date'
      ]
    end

    def events_table_row_data
      @events.map do |event|
        {
          id: event.id,
          url: edit_event_path(event.uuid),
          cells: event_table_row_data_cells(event)
        }
      end
    end

    def event_table_row_data_cells(event)
      [
        event.skos_prefLabel,
        event.edm_happenedAt.skos_prefLabel,
        event.edm_occurredAt.edm_begin,
        event.edm_occurredAt.edm_end
      ]
    end
  end
end
