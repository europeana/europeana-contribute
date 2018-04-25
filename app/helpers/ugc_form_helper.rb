# frozen_string_literal: true

# Helper module for common html atributes or other repetitve code
# that is used when generating the UGC form(s)
module UGCFormHelper
  def date_format_fallback_attributes
    { pattern: '\d{4}-\d{2}-\d{2}', placeholder: 'YYYY-MM-DD' }
  end

  # Constructs a select input for changing a contribution's AASM state
  #
  # Option values will be AASM events (not states), which can be fired on the
  # contribution.
  #
  # @param builder [ActionView::Helpers::FormBuilder] form builder
  # @param events [Array<AASM::Core::Event>] permitted AASM events to fire
  # @param selected [AASM::Core::Event] event selected to be fired
  def contribution_state_change_input(builder, events, selected)
    return nil unless events.present?

    state = t(builder.object.aasm_state_was, scope: 'contribute.contributions.states')
    hint = t('contribute.form.hints.contribution.aasm_state', state: state)

    builder.input(:aasm_state,
                  as: :select, collection: aasm_events_for_select(events),
                  selected: selected, include_blank: true,
                  label: t('contribute.form.labels.contribution.aasm_state'),
                  hint: hint)
  end

  def aasm_events_for_select(events)
    events.map { |event| [t(event.name, scope: 'contribute.contributions.events'), event.name] }
  end

  ##
  # To look up the mongo document ids and i18n labels for:
  # http://creativecommons.org/publicdomain/mark/1.0/
  # http://creativecommons.org/licenses/by-sa/4.0/
  # http://rightsstatements.org/page/CNE/1.0/
  def edm_rights_options
    %w(http://creativecommons.org/publicdomain/mark/1.0/
       http://creativecommons.org/licenses/by-sa/4.0/
       http://rightsstatements.org/vocab/CNE/1.0/).map do |url|
      license = cc_license_from_url(url)
      [edm_rights_label_html(cc_license_i18n_key(license)), license.id, 'data-license-url': url]
    end
  end

  def cc_license_from_url(rights_url)
    CC::License.find_by(rdf_about: rights_url)
  end

  def cc_license_i18n_key(license)
    uri = URI.parse(license.rdf_about)
    uri.host.tr('.', '_') + uri.path.tr('/.', '._').sub(/\.\z/, '')
  end

  def edm_rights_label_html(rights_key)
    scope = "contribute.campaigns.migration.form.labels.edm_web_resource.edm_rights.#{rights_key}"
    description = t('description', scope: scope)
    explanation = t('explanation', scope: scope)
    "<span class='license-description'>#{description}</span>#{explanation}".html_safe
  end

  def edm_event_options
    EDM::Event.all.map do |event|
      [event.name, event.id]
    end
  end
end
