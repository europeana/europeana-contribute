# frozen_string_literal: true

module CampaignValidatableModel
  extend ActiveSupport::Concern

  included do
    validate :campaign_validator
  end

  def campaign_validator
    validator_class = campaign_validator_class
    return if validator_class.nil?
    validates_with validator_class
  end

  def campaign_validator_class_name
    return nil unless respond_to?(:campaign) && campaign.present?

    @campaign_validator_class_name ||= begin
      'Campaigns::' + campaign.dc_identifier.classify + 'Validator'
    end
  end

  def campaign_validator_class
    class_name = campaign_validator_class_name
    return nil if class_name.nil?
    class_name.safe_constantize || CampaignValidator
  end
end
