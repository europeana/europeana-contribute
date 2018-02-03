# frozen_string_literal: true

##
# Pages with styleguide assets (CSS, JS, images)
module AssettedView
  extend ActiveSupport::Concern

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
      {
        name: 'enableFormValidation',
        value: feature_toggle_enabled?('ENABLE_JS_FORM_VALIDATION'),
        unquoted: true
      },
      {
        name: 'enableFormSave',
        value: feature_toggle_enabled?('ENABLE_JS_FORM_SAVE'),
        unquoted: true
      }
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

  # Checks environment to detect whether a feature is toggled on
  #
  # A feature is toggled on if its environment variable is set, and not "0" or
  # "false".
  #
  # @param env_var [String] environment variable name
  # TODO: move this somewhere usable by any section of the code
  def feature_toggle_enabled?(env_var)
    ENV.key?(env_var) && !%w(0 false).include?(ENV[env_var])
  end

  def js_application_requirements
    [
      asset_path('application.js'),
      asset_path("/javascripts/i18n/#{I18n.locale}.js")
    ]
  end

  def js_page_name
    "#{params[:controller]}/#{params[:action]}"
  end
end
