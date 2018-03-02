# frozen_string_literal: true

# Helper module for common html atributes or other repetitve code
# that is used when generating the ugc form(s)
module UGCFormHelper
  def date_format_fallback_attributes
    { pattern: '\d{4}-\d{2}-\d{2}', placeholder: 'YYYY-MM-DD' }
  end

  ##
  # To look up the mongo documents for:
  # https://creativecommons.org/publicdomain/mark/1.0/
  # https://creativecommons.org/licenses/by-sa/4.0/
  # http://rightsstatements.org/page/CNE/1.0/
  def edm_rights_options
    [
      ['public_domain_mark', rights_id_from_url('http://creativecommons.org/publicdomain/mark/1.0/')],
      ['creative_commons_attribution_share_alike', rights_id_from_url('http://creativecommons.org/licenses/by-sa/4.0/')],
      ['copyright_not_evaluated', rights_id_from_url('http://rightsstatements.org/vocab/CNE/1.0/')]
    ]
  end

  def rights_id_from_url(rights_url)
    CC::License.find_by(rdf_about: rights_url).id
  end
end
