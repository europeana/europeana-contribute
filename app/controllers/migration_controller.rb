# frozen_string_literal: true

class MigrationController < ApplicationController
  layout false

  def index; end

  def new
    @story = new_story
    build_story_associations_unless_present(@story)
  end

  def create
    @story = new_story
    @story.assign_attributes(story_params)

    if [validate_humanity, @story.valid?].all?
      @story.save
      flash[:notice] = 'Thank you for sharing your story!'
      redirect_to action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      # flash.now[:error] = errors
      render action: :new, status: 400
    end
  end

  private

  def errors
    @story.errors.full_messages +
      @story.edm_aggregatedCHO.errors.full_messages +
      @story.edm_isShownBy.errors.full_messages
  end

  def new_story
    Story.new(story_defaults)
  end

  def build_story_associations_unless_present(story)
    story.edm_aggregatedCHO.build_dc_contributor unless story.edm_aggregatedCHO.dc_contributor.present?
    story.edm_aggregatedCHO.dc_subject_agents.build unless story.edm_aggregatedCHO.dc_subject_agents.present?
    story.edm_aggregatedCHO.dcterms_spatial_places.build while story.edm_aggregatedCHO.dcterms_spatial_places.size < 2
    story.build_edm_isShownBy unless story.edm_isShownBy.present?
    story.edm_isShownBy.build_dc_creator unless story.edm_isShownBy.dc_creator.present?
  end

  def story_defaults
    {
      edm_provider: 'Europeana Migration',
      edm_dataProvider: 'Europeana Stories',
      edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
      edm_aggregatedCHO_attributes: {
        dc_language: I18n.locale.to_s
      }
    }
  end

  def story_params
    params.require(:story).
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
      verify_recaptcha(model: @story)
    end
  end
end
