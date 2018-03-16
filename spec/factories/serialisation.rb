# frozen_string_literal: true

FactoryBot.define do
  factory :serialisation, class: Serialisation do
    format 'rdfxml'
    contribution { build(:contribution) }
    data '<?xml version="1.0" encoding="UTF-8"?><rdf:RDF></rdf:RDF>'
  end
end
