# frozen_string_literal: true

RSpec.describe RDF::Graphable::Exclusion do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable::Exclusion

      attr_accessor :rdf_graph

      define_callbacks :graph

      field :foaf_mbox, type: String
      field :foaf_name, type: String
      field :skos_prefLabel, type: String

      graphs_without(RDF::Vocab::FOAF.mbox, RDF::Vocab::FOAF.name)

      def to_rdf
        run_callbacks :graph do
          uri = RDF::URI.new(id)
          graph = RDF::Graph.new
          graph << [uri, RDF::Vocab::FOAF.mbox, foaf_mbox] unless foaf_mbox.nil?
          graph << [uri, RDF::Vocab::FOAF.name, foaf_name] unless foaf_name.nil?
          graph << [uri, RDF::Vocab::SKOS.prefLabel, skos_prefLabel] unless skos_prefLabel.nil?
          self.rdf_graph = graph
        end
        self.rdf_graph
      end
    end
  end

  describe '#graphs_without' do
    let(:model_instance) do
      model_class.new(foaf_mbox: 'me@example.org', foaf_name: 'My Name', skos_prefLabel: 'Nickname')
    end

    it 'excludes specified predicates' do
      model_instance.to_rdf
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.mbox).count).to be_zero
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count).to be_zero
    end

    it 'retains other predicates' do
      model_instance.to_rdf
      expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::SKOS.prefLabel).count).not_to be_zero
    end
  end
end
