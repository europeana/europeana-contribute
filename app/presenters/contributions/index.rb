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
        has_campaigns: @campaigns.present?,
        campaigns: contributions_campaigns,
        has_events: @events.present?,
        events: contributions_events,
        table: {
          has_row_selectors: false, # until we make use of the buttons
          head_data: contributions_table_head_data,
          row_data: contributions_table_row_data
        }
      }
    end

    def contributions_campaigns
      campaigns = @campaigns.map do |campaign|
        {
          url: contributions_path(params.permit(:event_id, :campaign_id).merge(campaign_id: campaign.id)),
          label: campaign.dc_identifier,
          is_selected: @selected_campaign.present? && campaign == @selected_campaign
        }
      end
      campaigns.unshift(url: contributions_path(params.permit(:event_id)), label: '', is_selected: @selected_campaign.blank?)
    end

    def contributions_events
      events = @events.map do |event|
        {
          url: contributions_path(params.permit(:event_id, :campaign_id).merge(event_id: event.id)),
          label: event.name,
          is_selected: @selected_event.present? && event == @selected_event
        }
      end
      events.unshift(url: contributions_path(params.permit(:event_id, :campaign_id).merge(event_id: 'none')), label: t('filters.events.none'), is_selected: @selected_event == 'none')
      events.unshift(url: contributions_path(params.permit(:campaign_id)), label: '', is_selected: @selected_event.blank?)
    end

    def contributions_table_head_data
      [
        t('table.headings.name'),
        t('table.headings.title'),
        t('table.headings.ticket'),
        t('table.headings.date'),
        t('table.headings.status'),
        t('table.headings.media'),
        t('thumbnail', scope: 'contribute.actions'),
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
        table_cell(contribution_thumbnail_cell(contribution), row_link: false),
        (@deletion_enabled ? table_cell(contribution_delete_cell(contribution), row_link: false) : nil)
      ].compact
    end

    def contribution_thumbnail_cell(contribution)
      if contribution[:thumbnailable?]
        view.link_to(
          t('thumbnail', scope: 'contribute.actions'),
          thumbnail_contribution_path(contribution[:uuid])
        )
      else
        '✘'
      end
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
