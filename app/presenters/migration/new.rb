# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          text: errors + aggregation_form
        }
      end
    end

    def page_content_heading
      'Tell your story'
    end

    def fields
      {
        items: [
          {
            is_required: true,
            label:      'Media',
            name:       'ore_aggregation[edm_isShownBy_attributes][media]',
            type:       'file'
          },
          {
            label:      'Define a title for this item',
            name:       'ore_aggregation[edm_aggregatedCHO_attributes][dc_title]'
          },
          {
            label:      'What is the language of the text in this item?',
            name:       'ore_aggregation[edm_aggregatedCHO_attributes][dc_language]',
            is_select:  true,
            items: [
              {
                label: 'English',
                value: 'en'
              },
              {
                is_selected: true,
                label: 'Greek',
                value: 'hl'
              },
              {
                label: 'Italian',
                value: 'it'
              }
            ]
          },
          {
            label:       'Tell us the story of this object - including a description',
            name:        'ore_aggregation[edm_aggregatedCHO_attributes][dc_description]',
            is_textarea: 'true'
          },
          {
            label:       'Type',
            name:        'ore_aggregation[edm_aggregatedCHO_attributes][edm_type]',
            is_select:   true,
            items: [
              {
                label: 'Image',
                value: 'image'
              },
              {
                label: 'Text',
                value: 'text'
              },
              {
                label: 'Video',
                value: 'video'
               }
            ],
          },
          {
            label: 'What\'s your name?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_contributor_attributes][foaf_name]'
          },
          {
            label: 'Who created this item?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_creator_attributes][foaf_name]'
          },
          {
            label: 'When was this item created?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dcterms_created]'
          },
          {
            label: 'When was the item created?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dcterms_created]',
            type: 'date'
          },
          {
            label: 'Where is the item currently located?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_currentLocation]'
          },
          {
            is_required: true,
            is_select:  true,
            items: [
              {
                label: 'https://creativecommons.org/licenses/by-sa/4.0',
                value: '5a2e60bb2cfcc36e16277e42'
              },
              {
                label: 'https://creativecommons.org/licenses/by/4.0',
                value: '5a2e60bb2cfcc36e16277e43'
              },
              {
                label: 'https://creativecommons.org/publicdomain/mark/1.0/',
                value: '5a2e60bb2cfcc36e16277e44'
              },
              {
                label: 'https://creativecommons.org/publicdomain/zero/1.0/',
                value: '5a2e60bb2cfcc36e16277e45'
              }
            ],
            label: 'EDM Rights',
            name: 'ore_aggregation[edm_rights]'
          }
        ]
      }
    end

    protected

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end

    def aggregation_form
      @view.render partial: 'aggregation_form'
    end
  end
end
