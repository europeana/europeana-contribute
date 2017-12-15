# frozen_string_literal: true

module Migration
  class New < ApplicationPresenter
    include FormFillingView

    scopes_form_field_labels 'site.campaigns.migration'

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
          { name: 'action', value: migration_index_path }
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
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_title),
          {
            is_subset: true,
            fields: {
              legend: 'Media',
              items: [
                form_field_for(@aggregation, :edm_isShownBy, :media, required: true, subset: false, type: 'file'),
                form_field_for(@aggregation, :edm_isShownBy, :dc_rights, subset: false)
              ]
            }
          },
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_language,
                         select: true,
                         items: [blank_item] + EDM::ProvidedCHO.dc_language_enum.map { |lang| { label: lang.first, value: lang.last } }),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_description, textarea: true),
          form_field_for(@aggregation, :edm_aggregatedCHO, :edm_type,
                         required: true, select: true,
                         items: [blank_item] + EDM::ProvidedCHO.edm_type_enum.map { |type| { label: type, value: type } }),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_contributor, :foaf_name),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dc_creator, :foaf_name),
          form_field_for(@aggregation, :edm_aggregatedCHO, :dcterms_created),
          form_field_for(@aggregation, :edm_aggregatedCHO, :edm_currentLocation,
                         autocomplete: true, data_url: vocabularies_europeana_places_path, data_param: 'q'),
          form_field_for(@aggregation, :edm_rights,
                         required: true, select: true,
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
