# frozen_string_literal: true

class ApplicationPresenter < ::Europeana::Styleguide::View
  include ActionView::Helpers::TextHelper
  include AssettedView

  delegate :form_authenticity_token, :flash, :lookup_context, :params, to: :view
  delegate :logger, to: Rails
  delegate :t, to: I18n

  def page_title
    [page_content_heading, site_title].flatten.reject(&:blank?).join(' - ')
  end

  # Override in view subclasses for use in #page_title
  def page_content_heading
    ''
  end

  def flash_notice
    flash[:notice]
  end

  def cookie_disclaimer
    {
      more_link: 'https://www.europeana.eu/portal/rights/privacy.html'
    }
  end

  def log_out_link
    return unless current_user
    {
      url: destroy_user_session_path,
      label: t('sign_out', scope: 'contribute.actions')
    }
  end

  def navigation
    mustache[:navigation] ||= begin
      {
        global: {
          options: {
            search_active: false,
            settings_active: true
          },
          logo: {
            url: root_path,
            text: site_title
          }
        },
        home_url: root_url
      }
    end
  end

  def method_missing(method, *args, &block)
    if url_or_path_helper_method?(method)
      helpers.send(method, *args, &block)
    else
      logger.debug("Method missing: #{self.class}##{method}")
      nil
    end
  end

  def respond_to_missing?(method, include_private = false)
    super(method, include_private) || url_or_path_helper_method?(method)
  end

  def js_vars
    [
      { name: 'googleAnalyticsKey', value: config.x.google.analytics_key }
    ] + super
  end

  protected

  def url_or_path_helper_method?(method)
    method.to_s.end_with?('_path', '_url') && helpers.respond_to?(method)
  end

  def js_array(array)
    '[' + array.map { |value| "'#{value}'" }.join(',') + ']'
  end

  def site_title
    I18n.t('contribute.site.name')
  end

  def mustache
    @mustache ||= {}
  end

  def config
    Rails.application.config
  end
end
