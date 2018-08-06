# frozen_string_literal: true

##
# Pages with styleguide assets (CSS, JS, images)
module AssettedView
  extend ActiveSupport::Concern
  include Europeana::I18n::JsTranslationsHelper

  def css_files
    [
      {
        path: styleguide_url('/css/search/screen.css'),
        media: 'all'
      }
    ]
  end

  def js_vars
    [
      {
        name: 'pageName',
        value: js_page_name
      },
      {
        name: 'requirementsApplication',
        value: js_application_requirements,
        unquoted: true
      },
      feature_toggle_js_var('enableFormValidation', 'ENABLE_JS_FORM_VALIDATION'),
      feature_toggle_js_var('enableFormSave', 'ENABLE_JS_FORM_SAVE')
    ]
  end

  def js_files
    [
      {
        path: styleguide_url('/js/modules/require.js'),
        data_main: styleguide_url('/js/modules/main/templates/main-collections')
      }
    ]
  end

  protected

  def feature_toggle_js_var(js_var, env_var)
    {
      name: js_var,
      value: Environment.feature_toggled?(env_var),
      unquoted: true
    }
  end

  def js_application_requirements
    [
      asset_path('application.js')
    ] + js_translation_files
  end

  def js_page_name
    "#{params[:controller]}/#{params[:action]}"
  end
end
