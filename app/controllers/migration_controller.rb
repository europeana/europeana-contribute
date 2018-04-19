# frozen_string_literal: true

# NOTE: params[:uuid] is expected to be the UUID of the CHO, not the contribution
#       or aggregation because the CHO is the "core" object and others
#       supplementary, and its UUID will be published and need to be permanent.
class MigrationController < ApplicationController
  include Recaptchable

  def index; end

  def new
    @contribution = new_contribution
    formify_contribution(@contribution)
  end

  def create
    @contribution = new_contribution

    assign_attributes_to_contribution(@contribution)

    if [validate_humanity, @contribution.valid?].all?
      @contribution.save
      flash[:notice] = t('contribute.campaigns.migration.pages.create.flash.success')
      redirect_to action: :index, c: 'eu-migration'
    else
      formify_contribution(@contribution)
      render action: :new, status: 400
    end
  end

  def edit
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    @contribution = cho.edm_aggregatedCHO_for.contribution
    authorize! :edit, @contribution
    @deletion_enabled = true if current_user_can?(:wipe, @contribution) && @contribution.removable?
    @permitted_aasm_events = permitted_aasm_events
    formify_contribution(@contribution)
    render action: :new
  end

  def update
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    @contribution = cho.edm_aggregatedCHO_for.contribution
    authorize! :edit, @contribution

    assign_attributes_to_contribution(@contribution)

    @permitted_aasm_events = permitted_aasm_events
    @selected_aasm_event = aasm_event_param
    @contribution.aasm.fire(@selected_aasm_event.to_sym) unless @selected_aasm_event.blank?

    if @contribution.valid?
      @contribution.save
      flash[:notice] = t('contribute.campaigns.migration.pages.update.flash.success')
      redirect_to controller: :contributions, action: :index, c: 'eu-migration'
    else
      formify_contribution(@contribution)
      render action: :new, status: 400
    end
  end

  private

  def campaign
    @campaign ||= Campaign.find_by(dc_identifier: 'migration')
  end

  def assign_attributes_to_contribution(contribution)
    contribution.assign_attributes(contribution_params)
    contribution.ore_aggregation.edm_aggregatedCHO.dc_subject.push(campaign.dc_subject)
  end

  def new_contribution
    contribution = Contribution.new(contribution_defaults)
    # Mark the contribution as published already to support state-specific validations
    contribution.publish unless current_user_can?(:save_draft, Contribution)
    contribution
  end

  def formify_contribution(contribution)
    contribution.ore_aggregation.edm_aggregatedCHO.build_dc_contributor_agent if contribution.ore_aggregation.edm_aggregatedCHO.dc_contributor_agent.nil?
    contribution.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.build unless contribution.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.present?
    contribution.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.push('') until contribution.ore_aggregation.edm_aggregatedCHO.dcterms_spatial.size == 2
    contribution.ore_aggregation.build_edm_isShownBy if contribution.ore_aggregation.edm_isShownBy.nil?
    contribution.ore_aggregation.edm_aggregatedCHO.dc_subject.delete(campaign.dc_subject)
  end

  def contribution_defaults
    {
      campaign: campaign,
      created_by: current_user,
      ore_aggregation_attributes: {
        edm_dataProvider: Rails.configuration.x.edm.data_provider,
        edm_provider: Rails.configuration.x.edm.provider,
        edm_rights: CC::License.find_by(rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/'),
        edm_aggregatedCHO_attributes: {
          dc_language: [I18n.locale.to_s]
        }
      }
    }
  end

  def permitted_aasm_events
    @contribution.aasm.events(permitted: true, reject: :wipe)
  end

  def aasm_event_param
    params.require(:contribution).permit(:aasm_state)[:aasm_state]
  end

  def contribution_params
    params.require(:contribution).
      permit(:age_confirm, :guardian_consent, :content_policy_accept, :display_and_takedown_accept,
             ore_aggregation_attributes: {
               edm_aggregatedCHO_attributes: [
                 :edm_wasPresentAt_id, {
                   dc_contributor_agent_attributes: [:skos_prefLabel, { foaf_mbox: [], foaf_name: [] }],
                   dc_subject_agents_attributes: [:id, :_destroy, { foaf_name: [] }],
                   dcterms_spatial: [], dcterms_spatial_autocomplete: [],
                   dc_identifier: [], dc_title: [], dc_description: [],
                   dc_subject: [], dc_subject_autocomplete: [],
                   dc_type: [], dcterms_created: [], dc_language: []
                 }
               ],
               edm_isShownBy_attributes: [:media, :media_cache, :remove_media, :edm_rights_id, { dc_creator: [], dc_description: [], dc_type: [], dc_type_autocomplete: [], dcterms_created: [] }],
               edm_hasViews_attributes: [:id, :_destroy, :media, :media_cache, :remove_media, :edm_rights_id, { dc_creator: [], dc_description: [], dc_type: [], dc_type_autocomplete: [], dcterms_created: [] }]
             })
  end
end
