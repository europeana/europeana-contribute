# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'CC'
  inflect.acronym 'CHO'
  inflect.acronym 'DC'
  inflect.acronym 'DCAT'
  inflect.acronym 'DCTERMS'
  inflect.acronym 'EDM'
  inflect.acronym 'FOAF'
  inflect.acronym 'OAI'
  inflect.acronym 'ORE'
  inflect.acronym 'rdaGr2'
  inflect.acronym 'RDF'
  inflect.acronym 'SKOS'
  inflect.acronym 'SVCS'
  inflect.acronym 'UGC'
  inflect.acronym 'WGS84'
end
