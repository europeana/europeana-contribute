# frozen_string_literal: true

# Model validations for stories submitted within one campaign
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
end
