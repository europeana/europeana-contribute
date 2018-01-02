# frozen_string_literal: true

module AutocompletableModel
  extend ActiveSupport::Concern

  def autocompletes(attribute_name, **options)
    @autocompleted_attributes ||= {}
    @autocompleted_attributes[attribute_name] = {}
    @autocompleted_attributes[attribute_name][:options] = options

    unless respond_to?(:autocompleted_attributes)
      define_singleton_method(:autocompleted_attributes) do
        @autocompleted_attributes
      end
    end

    define_singleton_method("#{attribute_name}_text") do
      @autocompleted_attributes[attribute_name][:value]
    end

    define_singleton_method(:"#{attribute_name}_text=") do |value|
      @autocompleted_attributes[attribute_name][:value] = value
    end

    define_singleton_method("#{attribute_name}_value") do
      attributes[attribute_name]
    end

    define_singleton_method(:"#{attribute_name}_value=") do |value|
      attributes[attribute_name] = value
    end
  end
end
