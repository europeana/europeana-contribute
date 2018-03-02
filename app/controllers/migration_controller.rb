# frozen_string_literal: true

class MigrationController < ApplicationController
  include Recaptchable

  def index; end

  def new
    @contribution = new_contribution
    build_contribution_associations_unless_present(@contribution)
  end

  def create
    @contribution = new_contribution
    @contribution.assign_attributes(contribution_params)

    if [validate_humanity, @contribution.valid?].all?
      @contribution.save
      flash[:notice] = t('contribute.campaigns.migration.pages.create.flash.success')
      redirect_to action: :index, c: 'eu-migration'
    else
      build_contribution_associations_unless_present(@contribution)
      render action: :new, status: 400
    end
  end

  def edit
    @contribution = Contribution.find(params[:id])
    authorize! :edit, @contribution
    @permitted_aasm_events = permitted_aasm_events
    build_contribution_associations_unless_present(@contribution)
    render action: :new
  end

  def update
    @contribution = Contribution.find(params[:id])
    authorize! :edit, @contribution

    @contribution.assign_attributes(contribution_params)

    @permitted_aasm_events = permitted_aasm_events
    @selected_aasm_event = aasm_event_param
    @contribution.aasm.fire(@selected_aasm_event.to_sym) unless @selected_aasm_event.blank?

    if @contribution.valid?
      @contribution.save
      flash[:notice] = t('contribute.campaigns.migration.pages.update.flash.success')
      redirect_to controller: :contributions, action: :index, c: 'eu-migration'
    else
      build_contribution_associations_unless_present(@contribution)
      render action: :new, status: 400
    end
  end

  private

  def new_contribution
    contribution = Contribution.new(contribution_defaults)
    # Mark the contribution as published already to support state-specific validations
    contribution.publish unless current_user_can?(:save_draft, Contribution)
    contribution
  end

  def build_contribution_associations_unless_present(contribution)
    contribution.ore_aggregation.edm_aggregatedCHO.build_dc_contributor_agent if contribution.ore_aggregation.edm_aggregatedCHO.dc_contributor_agent.nil?
    contribution.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.build unless contribution.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.present?
    contribution.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.push('') until contribution.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.size == 2
    contribution.ore_aggregation.build_edm_isShownBy if contribution.ore_aggregation.edm_isShownBy.nil?
  end

  def contribution_defaults
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
    @contribution.aasm.events(permitted: true)
  end

  def aasm_event_param
    params.require(:contribution).permit(:aasm_state)[:aasm_state]
  end

  def contribution_params
    params.require(:contribution).
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
               edm_isShownBy_attributes: %i(dc_creator dc_description dc_type dcterms_created media media_cache remove_media),
               edm_hasViews_attributes: [%i(id _destroy dc_creator dc_description dc_type dcterms_created media media_cache remove_media)]
             })
  end
end
