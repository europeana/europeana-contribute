# frozen_string_literal: true

module Campaigns
  module Europeana
    # Model validations for stories submitted in the Migration campaign
    class MigrationValidator < CampaignValidator
      protected

      def validate_edm_provided_cho(record)
        record.errors.add(:dc_title, I18n.t('errors.messages.blank')) unless record.dc_title?
        record.errors.add(:dc_description, I18n.t('errors.messages.blank')) unless record.dc_description?
      end

      def validate_edm_agent(record)
        return unless record.dc_contributor_for?
        record.errors.add(:foaf_mbox, I18n.t('errors.messages.blank')) unless record.foaf_mbox?
        record.errors.add(:foaf_name, I18n.t('errors.messages.blank')) unless record.foaf_name?
        record.errors.add(:skos_prefLabel, I18n.t('errors.messages.blank')) unless record.skos_prefLabel?
      end
    end
  end
end
