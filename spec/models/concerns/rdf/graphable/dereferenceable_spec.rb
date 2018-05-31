# frozen_string_literal: true

RSpec.describe RDF::Graphable::Dereferenceable do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Dereferenceable

      field :dc_subject, type: String, default: ""
      field :dcterms_spatial, type: ArrayOf.type(String), default: []

      dereferences RDF::Vocab::DC.spatial
      dereferences RDF::Vocab::DC.subject, if: :dereferenced_subjects?

      def self.rdf_type
        RDF::URI.new('http://www.example.org/rdf/type')
      end

      def uuid
        SecureRandom.uuid
      end

      def dereferenced_subjects?
        false
      end
    end
  end

  before do
    stub_request(:get, "http://data.europeana.eu/place/base/40361").
      with(  headers: {
        'Accept'=>'application/ld+json, application/x-ld+json, application/rdf+xml, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, application/n-triples, text/plain;q=0.2, */*;q=0.1',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: '', headers: {})
  end

  describe '#dereferences' do
    let(:model_instance) do
      model_class.new(dc_subject: 'http://data.europeana.eu/concept/base/128', dcterms_spatial: 'http://data.europeana.eu/place/base/40361')
    end

    it 'includes the referenced resources' do
      pending
      model_instance.graph
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/place/base/40361').count).not_to be_zero
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/concept/base/128').count).to be_zero
    end

    it 'checks callback conditions' do
      pending
      allow(model_instance).to receive(:dereferenced_subjects?) { true }
      model_instance.graph
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/place/base/40361').count).not_to be_zero
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/concept/base/128').count).not_to be_zero
    end
  end
end
