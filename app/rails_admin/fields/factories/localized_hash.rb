# frozen_string_literal: true

#require 'rails_admin/config/fields/types/active_record_enum'

RailsAdmin::Config::Fields.register_factory do |parent, properties, fields|
  if properties.respond_to?(:property) && properties.property.is_a?(Mongoid::Fields::Localized)
    fields << RailsAdmin::Config::Fields::Types.load(:localized_hash).new(parent, properties.name, properties)
    true
  else
    false
  end
#   method_name = "#{properties.name}_enum"

#   # NOTICE: _method_name could be `to_enum` and this method defined in Object.
#   if !Object.respond_to?(method_name) && \
#      (model.respond_to?(method_name) || \
#          model.method_defined?(method_name))
#     fields << RailsAdmin::Config::Fields::Types::Enum.new(parent, properties.name, properties)
#     true
#   elsif model.respond_to?(:defined_enums) && model.defined_enums[properties.name.to_s]
#     fields << RailsAdmin::Config::Fields::Types::ActiveRecordEnum.new(parent, properties.name, properties)
#     true
#   else
#     false
#   end
end
