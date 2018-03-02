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

    if [validate_humanity, @story.valid?].all?
      @story.save
      flash[:notice] = t('contribute.campaigns.migration.pages.create.flash.success')
      redirect_to action: :index, c: 'eu-migration'
    else
      build_story_associations_unless_present(@story)
      render action: :new, status: 400
    end
  end

  def edit
    @story = Story.find(params[:id])
    authorize! :edit, @story
    @permitted_aasm_events = permitted_aasm_events
    build_story_associations_unless_present(@story)
    render action: :new
  end

  def update
    @story = Story.find(params[:id])
    authorize! :edit, @story

    @story.assign_attributes(story_params)

    @permitted_aasm_events = permitted_aasm_events
    @selected_aasm_event = aasm_event_param
    @story.aasm.fire(@selected_aasm_event.to_sym) unless @selected_aasm_event.blank?

    if @story.valid?
      @story.save
      flash[:notice] = t('contribute.campaigns.migration.pages.update.flash.success')
      redirect_to controller: :contributions, action: :index, c: 'eu-migration'
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
    story.ore_aggregation.build_edm_isShownBy if story.ore_aggregation.edm_isShownBy.nil?
    story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.push('') until story.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.size == 2
  end

  def story_defaults
    {
      created_by: current_user,
      ore_aggregation_attributes: {
        edm_dataProvider: Rails.configuration.x.edm.data_provider,
        edm_provider: Rails.configuration.x.edm.provider,
        edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
        edm_aggregatedCHO_attributes: {
          dc_language: I18n.locale.to_s
        }
      }
    }
  end

  def permitted_aasm_events
    @story.aasm.events(permitted: true)
  end

  def aasm_event_param
    params.require(:story).permit(:aasm_state)[:aasm_state]
  end

  def story_params
    params.require(:story).
      permit(:age_confirm, :guardian_consent, :content_policy_accept, :display_and_takedown_accept,
             ore_aggregation_attributes: {
               edm_aggregatedCHO_attributes: [
                 :dc_identifier, :dc_title, :dc_description, :dc_language, :dc_subject,
                 :dc_subject_autocomplete, :dc_type, :dcterms_created, :edm_wasPresentAt_id, {
                   dc_contributor_agent_attributes: %i(foaf_mbox foaf_name skos_prefLabel),
                   dc_subject_agents_attributes: [%i(id _destroy foaf_name rdaGr2_dateOfBirth rdaGr2_dateOfDeath rdaGr2_placeOfBirth
                                                     rdaGr2_placeOfBirth_autocomplete rdaGr2_placeOfDeath rdaGr2_placeOfDeath_autocomplete)],
                   dcterms_spatial: [],
                   dcterms_spatial_autocomplete: []
                 }
               ],
               edm_isShownBy_attributes: %i(dc_creator dc_description dc_type dcterms_created media media_cache remove_media edm_rights),
               edm_hasViews_attributes: [%i(id _destroy dc_creator dc_description dc_type dcterms_created media media_cache remove_media edm_rights)]
             })
  end
end
