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
        table: {
          head_data: stories_table_head_data,
          row_data: stories_table_row_data
        }
      }
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
        story.edm_aggregatedCHO&.dc_contributor&.foaf_name,
        story.edm_aggregatedCHO&.dc_identifier,
        story.created_at,
        '', # story.status,
        [story.edm_isShownBy, story.edm_hasViews].any?(&:present?) ? '✔' : '✘'
      ]
    end
  end
end
