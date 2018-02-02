# frozen_string_literal: true

class MigrationController < ApplicationController
  layout false

  def index; end

  def new
    @aggregation = new_aggregation
    build_aggregation_associations_unless_present(@aggregation)
  end

  def create
    @aggregation = new_aggregation
    @aggregation.assign_attributes(aggregation_params)
    annotate_dcterms_spatial_places(@aggregation)

    if [validate_humanity, @aggregation.valid?].all?
      @aggregation.save
      flash[:notice] = 'Thank you for sharing your story!'
      redirect_to action: :index, c: 'eu-migration'
    else
      build_aggregation_associations_unless_present(@aggregation)
      # flash.now[:error] = errors
      render action: :new, status: 400
    end
  end

  private

  def errors
    @aggregation.errors.full_messages +
      @aggregation.edm_aggregatedCHO.errors.full_messages +
      @aggregation.edm_isShownBy.errors.full_messages
  end

  def new_aggregation
    ORE::Aggregation.new(aggregation_defaults)
  end

  def build_aggregation_associations_unless_present(aggregation)
    aggregation.edm_aggregatedCHO.build_dc_contributor unless aggregation.edm_aggregatedCHO.dc_contributor.present?
    aggregation.edm_aggregatedCHO.dc_subject_agents.build unless aggregation.edm_aggregatedCHO.dc_subject_agents.present?
    aggregation.edm_aggregatedCHO.dcterms_spatial_places.build while aggregation.edm_aggregatedCHO.dcterms_spatial_places.size < 2
    aggregation.build_edm_isShownBy unless aggregation.edm_isShownBy.present?
    aggregation.edm_isShownBy.build_dc_creator unless aggregation.edm_isShownBy.dc_creator.present?
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

  def annotate_dcterms_spatial_places(aggregation)
    first = aggregation.edm_aggregatedCHO.dcterms_spatial_places.first
    unless first.nil? || first.blank_attributes?
      first.skos_note = 'Where the migration began'
    end
    last = aggregation.edm_aggregatedCHO.dcterms_spatial_places.last
    unless last.nil? || last.blank_attributes?
      last.skos_note = 'Where the migration ended'
    end
  end

  def aggregation_params
    params.require(:ore_aggregation).
      permit(edm_aggregatedCHO_attributes: [
               :dc_identifier, :dc_title, :dc_description, :dc_language, :dc_subject,
               :dc_subject_autocomplete, :dc_type, :dcterms_created, :edm_wasPresentAt_id, {
                 dc_contributor_attributes: %i(foaf_mbox foaf_name skos_prefLabel),
                 dc_subject_agents_attributes: [%i(_destroy foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth
                                                   rdaGr2_placeOfBirth_autocomplete rdaGr2_placeOfDeath rdaGr2_placeOfDeath_autocomplete)],
                 dcterms_spatial_places_attributes: [%i(owl_sameAs owl_sameAs_autocomplete)]
               }
             ],
             edm_isShownBy_attributes: [:dc_description, :dc_type, :dcterms_created, :media, :media_cache, {
               dc_creator_attributes: [:foaf_name]
             }],
             edm_hasViews_attributes: [[:_destroy, :dc_description, :dc_type, :dcterms_created, :media, :media_cache, {
               dc_creator_attributes: [:foaf_name]
             }]])
  end

  def validate_humanity
    if current_user
      true
    else
      verify_recaptcha(model: @aggregation)
    end
  end
end
