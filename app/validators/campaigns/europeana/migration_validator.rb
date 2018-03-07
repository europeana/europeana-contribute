# frozen_string_literal: true

module Campaigns
  module Europeana
    # Model validations for contributions submitted in the Migration campaign
    class MigrationValidator < CampaignValidator
      protected

      def validate_edm_provided_cho(record)
        %i(dc_title dc_description).each do |attr|
          validate_presence_of(record, attr)
        end
      end

      def validate_edm_web_resource(record)
        return if record.media_blank?
        validate_presence_of(record, :edm_rights)
      end


      def validate_edm_agent(record)
        return unless record.dc_contributor_agent_for?
        %i(foaf_mbox foaf_name skos_prefLabel).each do |attr|
          validate_presence_of(record, attr)
        end
      end
    end
  end
end
