# frozen_string_literal: true

module SimpleFormHelper
  # Override +SimpleForm::ActionViewExtensions::FormHelper::simple_form_for+ to
  # use +ApplicationFormBuilder+ as the default form builder.
  def simple_form_for(record, options = {}, &block)
    options[:builder] ||= ApplicationFormBuilder
    super(record, options, &block)
  end
end