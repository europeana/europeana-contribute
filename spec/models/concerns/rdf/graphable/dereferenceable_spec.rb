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

      dereferences RDF::Vocab::DC.spatial, only: %r(\Ahttp://data.europeana.eu/place)
      dereferences RDF::Vocab::DC11.subject, only: %r(\Ahttp://data.europeana.eu/concept), if: :dereferenced_subjects?

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
    stub_request(:get, 'http://data.europeana.eu/place/12345').
      to_return(status: 200, body: place_json_response(id: 12_345),
                headers: { content_type: 'application/json;charset=utf-8' })
    stub_request(:get, 'http://data.europeana.eu/concept/123').
      to_return(status: 200, body: concept_json_response(id: 123),
                headers: { content_type: 'application/json;charset=utf-8' })
  end

  describe '#dereferences' do
    let(:subject) { 'http://data.europeana.eu/concept/123' }
    let(:places) { ['http://data.europeana.eu/place/12345'] }
    let(:subject_rdf) { RDF::Resource.new('http://data.europeana.eu/concept/123') }
    let(:place_rdf) { RDF::Resource.new('http://data.europeana.eu/place/12345') }
    let(:model_instance) do
      model_class.new(dc_subject: subject, dcterms_spatial: places)
    end

    it 'includes the referenced resources' do
      model_instance.graph
      expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
      expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
    end

    context 'when a referenced europeana entity uri includes "base"' do
      before do
        stub_request(:get, 'http://data.europeana.eu/place/base/12345').
          to_return(status: 200, body: place_json_response(id: 'base/12345'),
                    headers: { content_type: 'application/json;charset=utf-8' })
      end

      let(:places) { ['http://data.europeana.eu/place/base/12345'] }
      let(:place_rdf) { RDF::Resource.new('http://data.europeana.eu/place/base/12345') }
      let(:model_instance) do
        model_class.new(dc_subject: subject, dcterms_spatial: places)
      end

      it 'includes the referenced resources' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
        expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
      end
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
      let(:places) { ['http://data.europeana.eu/place/12345', 'http://data.europeana.eu/geographical_locations/2000'] }
      let(:un_dereferencable_place_rdf) { RDF::Resource.new('http://data.europeana.eu/geographical_locations/2000') }
      it 'excludes the non dereferencable resources' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(subject: place_rdf).count).not_to be_zero
        expect(model_instance.rdf_graph.query(subject: un_dereferencable_place_rdf).count).to be_zero
        expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
      end
    end

    context 'when the resouce is not retrievalbe' do
      context 'because there is no response' do
        before do
          stub_request(:get, 'http://data.europeana.eu/place/12345').
            to_return(status: 404, body: 'Not found',
                      headers: { content_type: 'text/plain; charset=UTF-8' })
        end

        it 'should log the error' do
          expect(Rails.logger).to receive(:debug) { true }
          model_instance.graph
          expect(model_instance.rdf_graph.query(subject: place_rdf).count).to be_zero
          expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
        end
      end

      context 'because the response can not be parsed' do
        before do
          stub_request(:get, 'http://data.europeana.eu/place/12345').
            to_return(status: 200, body: '{Rubish}',
                      headers: { content_type: 'application/json; charset=UTF-8' })
        end

        it 'should log the error' do
          expect(Rails.logger).to receive(:debug) { true }
          model_instance.graph
          expect(model_instance.rdf_graph.query(subject: place_rdf).count).to be_zero
          expect(model_instance.rdf_graph.query(subject: subject_rdf).count).to be_zero
        end
      end
    end
  end
end
