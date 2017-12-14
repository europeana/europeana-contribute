# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    include FormFillingView

    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading
        }
      end
    end

    def page_content_heading
      'Tell your story'
    end

    def form
      {
        attributes: [
          { name: 'method', value: 'post' },
          { name: 'action', value: view.migration_index_path }
        ],
        fields: form_fields
      }
    end

    protected

    def form_fields
      {
        legend: 'Basic Data',
        items: [
          form_field('authenticity_token', form_authenticity_token, type: 'hidden'),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_title, label: 'Define a title for this item'),
          {
            is_subset: true,
            fields: {
              legend: 'Media',
              items: [
                form_field_for(@aggregation, :edm_isShownBy, :media,
                               label: 'Media File', required: true, subset: false, type: 'file'),
                form_field_for(@aggregation, :edm_isShownBy, :dc_rights, label: 'Media Rights', subset: false)
              ]
            }
          },
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_language,
                         label: 'What is the language of the text in this item?', select: true,
                         items: [blank_item] + EDM::ProvidedCHO.dc_language_enum.map { |lang| { label: lang.first, value: lang.last } }),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_description,
                         label: 'Tell us the story of this object - including a description', textarea: true),
          form_field_for(@aggregation, :edm_aggregatedCHO, :edm_type,
                         label: 'Type', required: true, select: true,
                         items: [blank_item] + EDM::ProvidedCHO.edm_type_enum.map { |type| { label: type, value: type } }),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_contributor, :foaf_name,
                         label: 'What\'s your name?'),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_creator, :foaf_name,
                         label: 'Who created this item?'),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dcterms_created,
                         label: 'When was the item created?', type: 'date'),
          form_field_for(@aggregation, :edm_aggregatedCHO, :edm_currentLocation,
                         label: 'Where is the item currently located?',
                         autocomplete: true, data_url: vocabularies_geonames_path, data_param: 'q'),
          form_field_for(@aggregation, :edm_rights,
                         required: true, select: true, label: 'EDM Rights',
                         items: [blank_item] + CC::License.all.map { |license| { label: license.rdf_about, value: license.id } })
        ]
      }
    end

    def errors
      return '' unless flash[:error].present?
      flash[:error].join('<br>')
    end
  end
end
