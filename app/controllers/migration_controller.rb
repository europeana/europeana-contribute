# frozen_string_literal: true

class MigrationController < ApplicationController
  include Recaptchable

  def index; end

  def new
    @story = new_story
    build_story_associations_unless_present(@story)
  end

  def create
    @story = new_story
    @story.assign_attributes(story_params)
    annotate_dcterms_spatial_places(@story)

    if [validate_humanity, @story.valid?].all?
      @story.save
      flash[:notice] = t('site.campaigns.migration.pages.create.flash.success')
      redirect_to action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      render action: :new, status: 400
    end
  end

  def edit
    @story = Story.find(params[:id])
    authorize! :edit, @story

    build_story_associations_unless_present(@story)
    render action: :new
  end

  def update
    @story = Story.find(params[:id])
    authorize! :edit, @story

    @story.assign_attributes(story_params)
    annotate_dcterms_spatial_places(@story)

    if @story.valid?
      @story.save
      flash[:notice] = 'Story saved.'
      redirect_to controller: :stories, action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      render action: :new, status: 400
    end
  end

  private

  def new_story
    story = Story.new(story_defaults)
    # Mark the story as published already to support state-specific validations
    story.publish unless current_user_can?(:save_draft, Story)
    story
  end

  def build_story_associations_unless_present(story)
    story.ore_aggregation.edm_aggregatedCHO.build_dc_contributor_agent if story.ore_aggregation.edm_aggregatedCHO.dc_contributor_agent.nil?
    story.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.build unless story.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.present?
    story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.build while story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size < 2
    story.ore_aggregation.build_edm_isShownBy if story.ore_aggregation.edm_isShownBy.nil?
    story.ore_aggregation.edm_isShownBy.build_dc_creator_agent if story.ore_aggregation.edm_isShownBy.dc_creator_agent.nil?
  end

  def story_defaults
    {
      created_by: current_user,
      ore_aggregation_attributes: {
        edm_provider: 'Europeana Migration',
        edm_dataProvider: 'Europeana Stories',
        edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
        edm_aggregatedCHO_attributes: {
          dc_language: I18n.locale.to_s
        }
      }
    }
  end

  def annotate_dcterms_spatial_places(story)
    first = story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.first
    first.skos_note = 'Where the migration began' unless first.blank?
    last = story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.last
    last.skos_note = 'Where the migration ended' unless last.blank?
  end

  def story_params
    params.require(:story).
      permit(ore_aggregation_attributes: {
               edm_aggregatedCHO_attributes: [
                 :dc_identifier, :dc_title, :dc_description, :dc_language, :dc_subject,
                 :dc_subject_autocomplete, :dc_type, :dcterms_created, :edm_wasPresentAt_id, {
                   dc_contributor_agent_attributes: %i(foaf_mbox foaf_name skos_prefLabel),
                   dc_subject_agents_attributes: [%i(id _destroy foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth
                                                     rdaGr2_placeOfBirth_autocomplete rdaGr2_placeOfDeath rdaGr2_placeOfDeath_autocomplete)],
                   dcterms_spatial_places_attributes: [%i(id owl_sameAs owl_sameAs_autocomplete)]
                 }
               ],
               edm_isShownBy_attributes: [:dc_description, :dc_type, :dcterms_created, :media, :media_cache, :remove_media, {
                 dc_creator_agent_attributes: [:foaf_name]
               }],
               edm_hasViews_attributes: [[:id, :_destroy, :dc_description, :dc_type, :dcterms_created, :media, :media_cache, :remove_media, {
                 dc_creator_agent_attributes: [:foaf_name]
               }]]
             })
  end
end
