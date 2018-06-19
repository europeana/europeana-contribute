# frozen_string_literal: true

RSpec.shared_context 'Entity API responses' do
  def place_json_response(id: 12_345, name: 'Place Name', lat: '50', long: '10')
    {
      "@context": 'http://www.europeana.eu/schemas/context/entity.jsonld',
      "altLabel": {
        "en": name
      },
      "id": "http://data.europeana.eu/place/base/#{id}",
      "lat": lat,
      "long": long,
      "prefLabel": {
        "": name,
        "en": name
      },
      "sameAs": [
        "sameAs": ["http://sws.geonames.org/#{name}/"]
      ],
      "type": 'Place'
    }.to_json
  end

  # Not used currently
  def concept_json_response(id: 123, name: 'Concept Name')
    {
      "@context": 'http://www.europeana.eu/schemas/context/entity.jsonld',
      "depiction": {
        "id": "http://en.wikipedia.org/wiki/Special:FilePath/#{name}.jpg",
        "source": "http://en.wikipedia.org/wiki/File:#{name}.jpg"
      },
      "exactMatch": ["http://da.dbpedia.org/resource/#{name}", "http://dbpedia.org/resource/#{name}"],
      "id": "http://data.europeana.eu/concept/base/#{id}",
      "note": {
        "en": ['Some descirptive note']
      },
      "prefLabel": {
        "": name,
        "en": name
      },
      "related": ["http://dbpedia.org/resource/Category:#{name}"],
      "type": 'Concept'
    }.to_json
  end
end
