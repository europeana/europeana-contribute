# frozen_string_literal: true

module Stories
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          stories: stories_content
        }
      end
    end

    # TODO: i18n
    def page_content_heading
      'Stories'
    end

    protected

    def stories_content
      {
        has_events: @events.present?,
        events: stories_events,
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: stories_table_head_data,
          row_data: stories_table_row_data
        }
      }
    end

    def stories_events
      @events.map do |event|
        {
          url: stories_path(event_id: event.id),
          label: event.name
        }
      end.unshift(url: stories_path, label: '')
    end

    # TODO: i18n
    def stories_table_head_data
      ['name', 'ticket number', 'submission date', 'status', 'contains media']
    end

    def stories_table_row_data
      @stories.map do |story|
        {
          id: story.id,
          url: '',
          cells: story_table_row_data_cell(story)
        }
      end
    end

    # [
    #   'edm:aggregatedCHO/dc:contributor/foaf:name',
    #   'edm:aggregatedCHO/dc:identifier',
    #   'created_at',
    #   'AASM status',
    #   'has media?
    # ]
    def story_table_row_data_cell(story)
      [
        story.ore_aggregation.edm_aggregatedCHO&.dc_contributor&.foaf_name,
        story.ore_aggregation.edm_aggregatedCHO&.dc_identifier,
        story.created_at,
        '', # story.status,
        [story.ore_aggregation.edm_isShownBy, story.ore_aggregation.edm_hasViews].any?(&:present?) ? '✔' : '✘'
      ]
    end
  end
end
