# frozen_string_literal: true

RSpec.shared_context 'stubbed Europeana entity schema' do
  EUROPEANA_ENTITY_SCHEMA = <<~SCHEMA
  {
    "@context": {
      "dc"       : "http://purl.org/dc/elements/1.1/",
      "dcterms"  : "http://purl.org/dc/terms/",
      "edm"      : "http://www.europeana.eu/schemas/edm/",
      "foaf"     : "http://xmlns.com/foaf/0.1/",
      "owl"      : "http://www.w3.org/2002/07/owl#",
      "rdaGr2"   : "http://rdvocab.info/ElementsGr2/",
      "rdf"      : "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "rdfs"     : "http://www.w3.org/2000/01/rdf-schema#",
      "skos"     : "http://www.w3.org/2004/02/skos/core#",
      "xsd"      : "http://www.w3.org/2001/XMLSchema#",
      "wgs84_pos": "http://www.w3.org/2003/01/geo/wgs84_pos#",
      "as"       : "http://www.w3.org/ns/activitystreams#",

      "id"   : { "@id": "@id"   , "@type": "@id" },
      "type" : { "@id": "@type" , "@type": "@id" },

      "Agent"   : { "@id": "edm:Agent"    },
      "Concept" : { "@id": "skos:Concept" },
      "Place"   : { "@id": "edm:Place"    },
      "TimeSpan": { "@id": "edm:TimeSpan" },

      "alt"                    : { "@id": "wgs84_pos:alt" },
      "altLabel"               : { "@id": "skos:altLabel"
                                 , "@container": "@language" },
      "begin"                  : { "@id": "edm:begin", "@language": null },
      "biographicalInformation": { "@id": "rdaGr2:biographicalInformation" },
      "broader"                : { "@id": "skos:broader", "@type": "@id" },
      "broadMatch"             : { "@id": "skos:broadMatch", "@type": "@id" },
      "closeMatch"             : { "@id": "skos:closeMatch", "@type": "@id" },
      "date"                   : { "@id": "dc:date", "@language": null },
      "dateOfBirth"            : { "@id": "rdaGr2:dateOfBirth", "@language": null },
      "dateOfDeath"            : { "@id": "rdaGr2:dateOfDeath", "@language": null },
      "dateOfEstablishment"    : { "@id": "rdaGr2:dateOfEstablishment", "@language": null },
      "dateOfTermination"      : { "@id": "rdaGr2:dateOfTermination", "@language": null },
      "end"                    : { "@id": "edm:end", "@language": null },
      "exactMatch"             : { "@id": "skos:exactMatch", "@type": "@id" },
      "gender"                 : { "@id": "rdaGr2:gender" },
      "hasMet"                 : { "@id": "edm:hasMet", "@type": "@id" },
      "hasPart"                : { "@id": "dcterms:hasPart", "@type": "@id" },
      "identifier"             : { "@id": "dc:identifier", "@language": null },
      "inScheme"               : { "@id": "skos:inScheme", "@type": "@id" },
      "isNextInSequence"       : { "@id": "edm:isNextInSequence", "@type": "@id" },
      "isPartOf"               : { "@id": "dcterms:isPartOf", "@type": "@id" },
      "isRelatedTo"            : { "@id": "edm:isRelatedTo", "@type": "@id"
                                 , "@container": "@set" },
      "lat"                    : { "@id": "wgs84_pos:lat", "@language": null },
      "long"                   : { "@id": "wgs84_pos:long", "@language": null },
      "name"                   : { "@id": "foaf:name"
                                 , "@container": "@language" },
      "note"                   : { "@id": "skos:note", "@container": "@language" },
      "notation"               : { "@id": "skos:notation", "@language": null },
      "narrower"               : { "@id": "skos:narrower", "@type": "@id" },
      "narrowMatch"            : { "@id": "skos:narrowMatch", "@type": "@id" },
      "prefLabel"              : { "@id": "skos:prefLabel"
                                 , "@container": "@language" },
      "placeOfBirth"           : { "@id": "rdaGr2:placeOfBirth" },
      "placeOfDeath"           : { "@id": "rdaGr2:placeOfDeath" },
      "professionOrOccupation" : { "@id": "rdaGr2:professionOrOccupation"
                                 , "@container": "@set" },
      "related"                : { "@id": "skos:related", "@type": "@id" },
      "relatedMatch"           : { "@id": "skos:relatedMatch", "@type": "@id" },
      "sameAs"                 : { "@id": "owl:sameAs", "@type": "@id"
                                 , "@container": "@set" },

      "total"                  : "as:totalItems"
    }
  }
SCHEMA

  before do
    stub_request(:get, 'http://www.europeana.eu/schemas/context/entity.jsonld').
      to_return(status: 200, body: EUROPEANA_ENTITY_SCHEMA, headers: { content_type: 'application/ld+json' })
  end
end
