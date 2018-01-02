# frozen_string_literal: true

module AutocompletedFields
  extend ActiveSupport::Concern

  def autocomplete(object, attribute_name, **options)
    object.extend(AutocompletableModel) unless object.is_a?(AutocompletableModel)
    object.autocompletes(attribute_name, options)
  end
end
