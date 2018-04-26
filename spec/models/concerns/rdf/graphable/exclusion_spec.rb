# frozen_string_literal: true

RSpec.describe RDF::Graphable::Exclusion do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Exclusion

      field :foaf_mbox, type: String
      field :foaf_name, type: String
      field :skos_prefLabel, type: String

      graphs_without RDF::Vocab::FOAF.mbox
      graphs_without RDF::Vocab::FOAF.name, if: :hide_name?

      def self.rdf_type
        RDF::URI.new('http://www.example.org/rdf/type')
      end

      def uuid
        SecureRandom.uuid
      end

      def hide_name?
        false
      end
    end
  end

  describe '#graphs_without' do
    let(:model_instance) do
      model_class.new(foaf_mbox: 'me@example.org', foaf_name: 'My Name', skos_prefLabel: 'Nickname')
    end

    it 'excludes specified predicates' do
      model_instance.graph
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.mbox).count).to be_zero
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count).not_to be_zero
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::SKOS.prefLabel).count).not_to be_zero
    end

    it 'checks callback conditions' do
      allow(model_instance).to receive(:hide_name?) { true }
      model_instance.graph
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.mbox).count).to be_zero
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count).to be_zero
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::SKOS.prefLabel).count).not_to be_zero
    end
  end
end
