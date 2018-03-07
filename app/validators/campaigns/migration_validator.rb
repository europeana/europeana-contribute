# frozen_string_literal: true

module Campaigns
  # Model validations for contributions submitted in the Migration campaign
  class MigrationValidator < CampaignValidator
    protected

    def validate_edm_provided_cho(record)
      PresenceOfAnyElementValidator.new(attributes: %i(dc_title dc_description)).validate(record)
    end

    def validate_edm_web_resource(record)
      return if record.media_blank?
      ActiveModel::Validations::PresenceValidator.new(attributes: %i(edm_rights_id)).validate(record)
    end

    def validate_edm_agent(record)
      return unless record.dc_contributor_agent_for?
      PresenceOfAnyElementValidator.new(attributes: %i(foaf_mbox foaf_name skos_prefLabel)).validate(record)
    end
  end
end
