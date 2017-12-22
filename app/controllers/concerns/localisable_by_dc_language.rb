# frozen_string_literal: true

module LocalisableByDCLanguage
  extend ActiveSupport::Concern

  # To handle localised Mongoid fields, all we should need do is set I18n.locale
  # to the value of the dc:language param (if present).
  #
  # with_dc_language_for_localisations(aggregation_params[:edm_aggregatedCHO_attributes][:dc_language]) do
  #   @aggregation.update(aggregation_params)
  # end
  def with_dc_language_for_localisations(dc_language)
    locale_was = I18n.locale
    I18n.locale = dc_language unless dc_language.blank?
    yield
    I18n.locale = locale_was
  end
end
