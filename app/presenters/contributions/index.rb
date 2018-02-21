# frozen_string_literal: true

module Contributions
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          stories: stories_content
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    protected

    def t(*args, **options)
      super(*args, options.merge(scope: 'pages.contributions.index'))
    end

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
          url: contributions_path(event_id: event.id),
          label: event.name,
          is_selected: @selected_event.present? && event == @selected_event
        }
      end.unshift(url: contributions_path, label: t('filters.events.all'), is_selected: @selected_event.blank?)
    end

    def stories_table_head_data
      [
        t('table.headings.name'),
        t('table.headings.ticket'),
        t('table.headings.date'),
        t('table.headings.status'),
        t('table.headings.media')
      ]
    end

    def stories_table_row_data
      @stories.map do |story|
        {
          id: story.id,
          url: edit_migration_path(story.id), # TODO: make this campaign-agnostic
          cells: story_table_row_data_cells(story)
        }
      end
    end

    def story_table_row_data_cells(story)
      [
        story.ore_aggregation.edm_aggregatedCHO&.dc_contributor_agent&.foaf_name,
        story.ore_aggregation.edm_aggregatedCHO&.dc_identifier,
        story.created_at,
        story.aasm_state,
        story.has_media? ? '✔' : '✘'
      ]
    end
  end
end
