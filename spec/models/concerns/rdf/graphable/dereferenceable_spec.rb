# frozen_string_literal: true

require 'support/shared_contexts/responses/entity_api_responses'

RSpec.describe RDF::Graphable::Dereferenceable do
  include_context 'Entity API responses'

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
    stub_request(:get, "http://data.europeana.eu/place/base/12345").
      to_return(status: 200, body: place_json_response(id: 12345), headers: { content_type: 'application/json;charset=utf-8' })
    stub_request(:get, "http://data.europeana.eu/concept/base/123").
      to_return(status: 200, body: concept_json_response(id: 123), headers: { content_type: 'application/json;charset=utf-8' })
  end

  describe '#dereferences' do
    let(:model_instance) do
      model_class.new(dc_subject: 'http://data.europeana.eu/concept/base/123', dcterms_spatial: 'http://data.europeana.eu/place/base/12345')
    end

    it 'includes the referenced resources' do
      model_instance.graph
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/place/base/12345').count).not_to be_zero
      expect(model_instance.rdf_graph.query('http://data.europeana.eu/concept/base/123').count).to be_zero
    end

    context 'when a callback condition is set to true' do
      before do
        allow(model_instance).to receive(:dereferenced_subjects?) { true }
      end

      it 'checks callback conditions' do
        model_instance.graph
        expect(model_instance.rdf_graph.query('http://data.europeana.eu/place/base/12345').count).not_to be_zero
        expect(model_instance.rdf_graph.query('http://data.europeana.eu/concept/base/123').count).not_to be_zero
      end
    end
  end
end
