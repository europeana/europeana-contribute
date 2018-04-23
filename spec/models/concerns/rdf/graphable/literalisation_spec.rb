# frozen_string_literal: true

RSpec.describe RDF::Graphable::Literalisation do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable::Literalisation

      attr_accessor :rdf_graph

      define_callbacks :graph

      field :dc_title, type: String
      field :dc_description, type: String

      graphs_as_literal(RDF::Vocab::DC11.title)

      def to_rdf
        run_callbacks :graph do
          uri = RDF::URI.new(id)
          graph = RDF::Graph.new
          graph << [uri, RDF::Vocab::DC11.title, dc_title] unless dc_title.nil?
          graph << [uri, RDF::Vocab::DC11.description, dc_description] unless dc_description.nil?
          self.rdf_graph = graph
        end
      end
    end
  end

  describe '#literalise_rdf_graph' do
    it 'literalises sparse graphs' do
      graph = RDF::Graph.new
      uri = RDF::URI.new(SecureRandom.uuid)
      graph << [uri, RDF::Vocab::DC11.title, 'Title']
      literalised = model_class.literalise_rdf_graph(graph, RDF::Vocab::DC11.title)
      expect(literalised).to be_a(RDF::Literal)
      expect(literalised.value).to eq('Title')
    end

    it 'discounts RDF type' do
      graph = RDF::Graph.new
      uri = RDF::URI.new(SecureRandom.uuid)
      graph << [uri, RDF.type, 'RDF type']
      graph << [uri, RDF::Vocab::DC11.title, 'Title']
      literalised = model_class.literalise_rdf_graph(graph, RDF::Vocab::DC11.title)
      expect(literalised).to be_a(RDF::Literal)
      expect(literalised.value).to eq('Title')
    end
  end

  describe '#literalise_rdf_graph!' do
    context 'with non-sparse graph' do
      let(:doc) { model_class.new(dc_title: 'My Title', dc_description: 'My description') }

      it 'is not literalised' do
        doc.to_rdf
        expect(doc.rdf_graph).not_to be_a(RDF::Literal)
      end
    end

    context 'with sparse graph' do
      let(:doc) { model_class.new(dc_title: 'My Title') }

      it 'is literalised' do
        doc.to_rdf
        expect(doc.rdf_graph).to be_a(RDF::Literal)
        expect(doc.rdf_graph.value).to eq('My Title')
      end
    end
  end
end
