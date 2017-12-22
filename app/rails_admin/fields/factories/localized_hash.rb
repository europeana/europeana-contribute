# frozen_string_literal: true

RailsAdmin::Config::Fields.register_factory do |parent, properties, fields|
  if properties.respond_to?(:property) && properties.property.is_a?(Mongoid::Fields::Localized)
    fields << RailsAdmin::Config::Fields::Types.load(:localized_hash).new(parent, properties.name, properties)
    true
  else
    false
  end
end
