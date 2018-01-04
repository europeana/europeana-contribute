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
    return nil unless respond_to?(:edm_provider) && edm_provider.present?

    @campaign_validator_class_name ||= begin
      'Campaigns::' + edm_provider.strip.gsub(' ', '::') + 'Validator'
    end
  end

  def campaign_validator_class
    class_name = campaign_validator_class_name
    class_name.nil? ? nil : class_name.safe_constantize
  end
end
