# frozen_string_literal: true

# Model validations for contributions submitted within one campaign
class CampaignValidator < ActiveModel::Validator
  def validate(record)
    method_name = validation_method_name(record)
    send(method_name, record) if respond_to?(method_name, true)
  end

  protected

  # @example
  #   validation_method_name(ORE::Aggregation.new) #=> :validate_ore_aggregation
  def validation_method_name(record)
    record_class = record.class.to_s.underscore.tr('/', '_')
    :"validate_#{record_class}"
  end

  def validate_edm_provided_cho(record)
    PresenceOfAnyElementValidator.new(attributes: %i(dc_title dc_description)).validate(record)
  end

  def validate_edm_web_resource(record)
    return if record.media_blank?

    ActiveModel::Validations::PresenceValidator.new(
      attributes: %i(edm_rights_id),
      message: I18n.t('contribute.campaigns.generic.form.validation.web-resource-license')
    ).validate(record)
  end

  def validate_edm_agent(record)
    return unless record.dc_contributor_agent_for?
    PresenceOfAnyElementValidator.new(attributes: %i(foaf_mbox foaf_name skos_prefLabel)).validate(record)
  end
end
