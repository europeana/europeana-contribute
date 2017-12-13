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

    def form
      '.erb alternative to .mustache'
    end

    def generic_form
      {
        attributes: [method: 'get', action: 'create'],
        fields: fieldset
      }
    end

    protected

    def form_field_with_id(field)
      field[:id] = sanitize_to_id(field[:name])
      field
    end

    def fieldset
      {
        legend: 'Basic Data',
        items: [
          {
            type: 'hidden',
            name: 'authenticity_token',
            value: form_authenticity_token,
            label: false
          },
          form_field_with_id({
            label: 'Define a title for this item',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_title]'
          }),
          {
            is_subset: true,
            fields: {
              legend: 'Media',
              items: [
                form_field_with_id({
                  label: 'Media File',
                  name: 'ore_aggregation[edm_isShownBy_attributes][media]',
                  is_required: true,
                  is_subset: false,
                  type: 'file'
                }),
                form_field_with_id({
                  label: 'Media Rights',
                  is_subset: false,
                  name: 'media_rights'
                })
              ]
            }
          },
          form_field_with_id({
            label: 'What is the language of the text in this item?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_language]',
            is_select:  true,
            items: [{ label: '', value: '' }] + EDM::ProvidedCHO.dc_language_enum.map { |lang| { label: lang.first, value: lang.last } }
          }),
          form_field_with_id({
            label: 'Tell us the story of this object - including a description',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_description]',
            is_textarea: 'true'
          }),
          form_field_with_id({
            label: 'Type',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_type]',
            is_required: true,
            is_select: true,
            items: [{ label: '', value: '' }] + EDM::ProvidedCHO.edm_type_enum.map { |type| { label: type, value: type } }
          }),
          form_field_with_id({
            label: 'What\'s your name?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_contributor_attributes][foaf_name]'
          }),
          form_field_with_id({
            label: 'Who created this item?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dc_creator_attributes][foaf_name]'
          }),
          form_field_with_id({
            label: 'When was the item created?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][dcterms_created]',
            type: 'date'
          }),
          form_field_with_id({
            label: 'Where is the item currently located?',
            name: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_currentLocation]',
            # value: 'http://sws.geonames.org/2650225'
            name_text: 'ore_aggregation[edm_aggregatedCHO_attributes][edm_currentLocation_text]',
            # name_value: 'Edinburgh',
            data_url: '/vocabularies/geonames',
            data_param: 'q'
          }),
          form_field_with_id({
            is_required: true,
            is_select: true,
            items: [{ label: '', value: '' }] + CC::License.all.map { |license| { label: license.rdf_about, value: license.id } },
            label: 'EDM Rights',
            name: 'ore_aggregation[edm_rights]'
          })
        ]
      }
    end

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end

    def aggregation_form
      @view.render partial: 'aggregation_form'
    end
  end
end
