# frozen_string_literal: true

require 'support/shared_contexts/responses/entity_api_responses'
require 'support/shared_contexts/responses/europeana_entity_schema'

RSpec.describe RDF::Graphable::Dereferenceable do
  include_context 'Entity API responses'
  include_context 'stubbed Europeana entity schema'

  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Dereferenceable

      field :dc_subject, type: String, default: ''
      field :dcterms_spatial, type: ArrayOf.type(String), default: []

      dereferences RDF::Vocab::DC.spatial, only: %r(\Ahttp://data.europeana.eu/place/base)
      dereferences RDF::Vocab::DC11.subject, only: %r(\Ahttp://data.europeana.eu/concept/base), if: :dereferenced_subjects?

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
    stub_request(:get, 'http://data.europeana.eu/place/base/12345').
      to_return(status: 200, body: place_json_response(id: 12_345),
                headers: { content_type: 'application/json;charset=utf-8' })
    stub_request(:get, 'http://data.europeana.eu/concept/base/123').
      to_return(status: 200, body: concept_json_response(id: 123),
                headers: { content_type: 'application/json;charset=utf-8' })
  end

  describe '#dereferences' do
    let(:subject) { 'http://data.europeana.eu/concept/base/123' }
    let(:places) { ['http://data.europeana.eu/place/base/12345'] }
    let(:subject_rdf) { RDF::Resource.new('http://data.europeana.eu/concept/base/123') }
    let(:place_rdf) { RDF::Resource.new('http://data.europeana.eu/place/base/12345') }
    let(:model_instance) do
      model_class.new(dc_subject: subject, dcterms_spatial: places)
    end

    it 'includes the referenced resources' do
      model_instance.graph
      expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
      expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
    end

    context 'when a callback condition is set to true' do
      before do
        allow(model_instance).to receive(:dereferenced_subjects?) { true }
      end

      it 'checks callback conditions' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
        expect(model_instance.rdf_graph.query(subject: subject_rdf).count).not_to be_zero
      end
    end

    context 'when the referenced resource is NOT dereferencable' do
      let(:places) { ['http://data.europeana.eu/place/base/12345', 'http://data.europeana.eu/place/extended/2000'] }
      let(:un_dereferencable_place_rdf) { RDF::Resource.new('http://data.europeana.eu/place/extended/2000') }
      it 'excludes the non dereferencable resources' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
        expect(model_instance.rdf_graph.query(subject: un_dereferencable_place_rdf).count).to be_zero
        expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
      end
    end
  end
end
