# frozen_string_literal: true

class ApplicationView < Europeana::Styleguide::View
  include AssettedView

  def page_title
    [page_content_heading, site_title].flatten.reject(&:blank?).join(' - ')
  end

  # Override in view subclasses for use in #page_title
  def page_content_heading
    ''
  end

  def cookie_disclaimer
    {
      more_link: 'https://www.europeana.eu/portal/rights/privacy.html'
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

  protected

  def js_array(array)
    '[' + array.map { |value| "'#{value}'" }.join(',') + ']'
  end

  def site_title
    'Europeana Stories'
  end

  def mustache
    @mustache ||= {}
  end

  def config
    Rails.application.config
  end
end
