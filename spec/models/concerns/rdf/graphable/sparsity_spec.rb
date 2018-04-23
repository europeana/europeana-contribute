# frozen_string_literal: true

RSpec.describe RDF::Graphable::Sparsity do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable::Sparsity

      attr_accessor :rdf_graph

      field :dc_title, type: String
      field :dc_description, type: String

      is_sparse_rdf_with_only(RDF::Vocab::DC11.title)

      def to_rdf
        uri = RDF::URI.new(id)
        graph = RDF::Graph.new
        graph << [uri, RDF::Vocab::DC11.title, dc_title] unless dc_title.nil?
        graph << [uri, RDF::Vocab::DC11.description, dc_description] unless dc_description.nil?
        graph
      end
    end
  end

  describe '#literalize_rdf_graph!' do
    context 'with non-sparse graph' do
      let(:doc) { model_class.new(dc_title: 'My Title', dc_description: 'My description') }

      it 'is not literalised' do
        doc.rdf_graph = doc.to_rdf
        expect { doc.literalize_rdf_graph! }.not_to(change { doc.rdf_graph })
      end
    end

    context 'with sparse graph' do
      let(:doc) { model_class.new(dc_title: 'My Title') }

      it 'is literalised' do
        doc.rdf_graph = doc.to_rdf
        expect { doc.literalize_rdf_graph! }.to(change { doc.rdf_graph })
        expect(doc.rdf_graph).to be_a(RDF::Literal)
        expect(doc.rdf_graph.value).to eq('My Title')
      end
    end
  end
end
