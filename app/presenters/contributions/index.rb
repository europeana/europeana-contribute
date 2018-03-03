# frozen_string_literal: true

module Contributions
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          contributions: contributions_content
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
      @events.map do |event|
        {
          url: contributions_path(event_id: event.id),
          label: event.name,
          is_selected: @selected_event.present? && event == @selected_event
        }
      end.unshift(url: contributions_path, label: t('filters.events.all'), is_selected: @selected_event.blank?)
    end

    def contributions_table_head_data
      [
        t('table.headings.name'),
        t('table.headings.ticket'),
        t('table.headings.date'),
        t('table.headings.status'),
        t('table.headings.media')
      ]
    end

    def contributions_table_row_data
      @contributions.map do |contribution|
        {
          id: contribution.id,
          url: edit_migration_path(contribution.id), # TODO: make this campaign-agnostic
          cells: contribution_table_row_data_cells(contribution)
        }
      end
    end

    def contribution_table_row_data_cells(contribution)
      [
        contribution.ore_aggregation.edm_aggregatedCHO&.dc_contributor_agent&.foaf_name,
        contribution.ore_aggregation.edm_aggregatedCHO&.dc_identifier,
        contribution.created_at,
        t(contribution.aasm_state, scope: 'contribute.contributions.states'),
        contribution.has_media? ? '✔' : '✘'
      ]
    end
  end
end
