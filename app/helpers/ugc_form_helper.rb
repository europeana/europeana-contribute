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
  # To look up the mongo documents for:
  # https://creativecommons.org/publicdomain/mark/1.0/
  # https://creativecommons.org/licenses/by-sa/4.0/
  # http://rightsstatements.org/page/CNE/1.0/
  def edm_rights_options
    [
      [edm_rights_label_html('public_domain'), rights_id_from_url('http://creativecommons.org/publicdomain/mark/1.0/')],
      [edm_rights_label_html('creative_commons_attribution_share_alike'), rights_id_from_url('http://creativecommons.org/licenses/by-sa/4.0/')],
      [edm_rights_label_html('copyright_not_evaluated'), rights_id_from_url('http://rightsstatements.org/vocab/CNE/1.0/')]
    ]
  end

  def rights_id_from_url(rights_url)
    CC::License.find_by(rdf_about: rights_url).id
  end

  def edm_rights_label_html(rights_key)
    scope = 'contribute.campaigns.migration.form.labels.edm_web_resource.edm_rights'
    html = "<span class='license-description'>#{t(rights_key + '.description', scope: scope)}</span>#{t(rights_key + '.explanation', scope: scope)}"
    html.html_safe
  end
end
