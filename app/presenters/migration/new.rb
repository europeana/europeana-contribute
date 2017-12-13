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
            type: 'hidden',
            name: 'authenticity_token',
            value: form_authenticity_token,
            label: false
          },
          {
            is_required: true,
            label: 'Media',
            name: 'ore_aggregation[edm_isShownBy_attributes][media]',
            type: 'file'
          },
          {
            label: 'Define a title for this item',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_title]'
          },
          {
            label: 'What is the language of the text in this item?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_language]',
            is_select:  true,
            items: [{ label: '', value: '' }] + EDM::ProvidedCHO.dc_language_enum.map { |lang| { label: lang.first, value: lang.last } }
          },
          {
            label: 'Tell us the story of this object - including a description',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_description]',
            is_textarea: 'true'
          },
          {
            label: 'Type',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_type]',
            is_select: true,
            items: [{ label: '', value: '' }] + EDM::ProvidedCHO.edm_type_enum.map { |type| { label: type, value: type } }
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
            label: 'When was the item created?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dcterms_created]',
            type: 'date'
          },
          {
            label: 'Where is the item currently located?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_currentLocation]',
            data_url: 'geonames_mapping',
            data_param: 'name'
          },
          {
            is_required: true,
            is_select: true,
            items: [{ label: '', value: '' }] + CC::License.all.map { |license| { label: license.rdf_about, value: license.id } },
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
