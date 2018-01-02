# frozen_string_literal: true

class MigrationController < ApplicationController
  include AutocompletedFields
  include LocalisableByDCLanguage

  layout false

  def index; end

  def new
    @aggregation = new_aggregation
  end

  def create
    @aggregation = new_aggregation

    dc_language = aggregation_params[:edm_aggregatedCHO_attributes][:dc_language]
    with_dc_language_for_localisations(dc_language) do
      @aggregation.update(aggregation_params)
    end

    if @aggregation.valid?
      @aggregation.save
      flash[:notice] = 'Thank you for sharing your story!'
      redirect_to action: :index
    else
      # flash.now[:error] = errors
      render action: :new
    end
  end

  private

  def errors
    @aggregation.errors.full_messages +
      @aggregation.edm_aggregatedCHO.errors.full_messages +
      @aggregation.edm_isShownBy.errors.full_messages
  end

  def new_aggregation
    ORE::Aggregation.new(aggregation_defaults).tap do |aggregation|
      aggregation.edm_aggregatedCHO.build_dc_contributor
      aggregation.edm_aggregatedCHO.build_dc_creator
      aggregation.build_edm_isShownBy

      autocomplete(aggregation.edm_aggregatedCHO, :dc_subject, url: vocabularies_unesco_path, param: 'q')
      autocomplete(aggregation.edm_aggregatedCHO.dc_creator, :rdaGr2_placeOfBirth, url: vocabularies_europeana_places_path, param: 'q')
      autocomplete(aggregation.edm_aggregatedCHO.dc_creator, :rdaGr2_placeOfDeath, url: vocabularies_europeana_places_path, param: 'q')
    end
  end

  def aggregation_defaults
    {
      edm_provider: 'Europeana Migration',
      edm_dataProvider: 'Europeana Stories',
      edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
      edm_aggregatedCHO_attributes: {
        dc_language: I18n.locale.to_s
      }
    }
  end

  def aggregation_params
    params.require(:ore_aggregation).
      permit(edm_aggregatedCHO_attributes: [
               :dc_identifier, :dc_title, :dc_description, :dc_language, :dc_subject_text,
               :dc_subject_value, :dc_type, :dcterms_created, :edm_wasPresentAt_id, {
                 dc_contributor_attributes: %i(foaf_mbox foaf_name skos_prefLabel),
                 dc_creator_attributes: %i(foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth rdaGr2_placeOfDeath)
               }
             ],
             edm_isShownBy_attributes: [:dc_description, :dc_type, :dcterms_created, :media, :media_cache, {
               dc_creator: :foaf_name
             }])
  end
end
