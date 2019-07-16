# frozen_string_literal: true

# @see https://pro.europeana.eu/page/available-rights-statements
%w(
  http://creativecommons.org/publicdomain/mark/1.0/
  http://rightsstatements.org/vocab/NoC-NC/1.0/
  http://rightsstatements.org/vocab/NoC-OKLR/1.0/
  http://creativecommons.org/publicdomain/zero/1.0/
  http://creativecommons.org/licenses/by/4.0/
  http://creativecommons.org/licenses/by-sa/4.0/
  http://creativecommons.org/licenses/by-nd/4.0/
  http://creativecommons.org/licenses/by-nc/4.0/
  http://creativecommons.org/licenses/by-nc-sa/4.0/
  http://creativecommons.org/licenses/by-nc-nd/4.0/
  http://rightsstatements.org/vocab/InC/1.0/
  http://rightsstatements.org/vocab/InC-EDU/1.0/
  http://rightsstatements.org/vocab/InC-OW-EU/1.0/
  http://rightsstatements.org/vocab/CNE/1.0/
).each do |license|
  CC::License.create!(rdf_about: license) unless CC::License.where(rdf_about: license).present?
end

unless Campaign.where(dc_identifier: 'migration').present?
  Campaign.create!(dc_identifier: 'migration', dc_subject: 'http://data.europeana.eu/concept/base/128')
end
unless Campaign.where(dc_identifier: 'europe-at-work').present?
  Campaign.create!(dc_identifier: 'europe-at-work', dc_subject: 'http://vocabularies.unesco.org/thesaurus/concept7068')
end
