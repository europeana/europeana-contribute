# frozen_string_literal: true

RSpec.describe RDF::Graphable::Literalisation do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Literalisation

      field :dc_title, type: String
      field :dc_description, type: String

      graphs_as_literal RDF::Vocab::DC11.title
      graphs_as_literal RDF::Vocab::DC11.description, if: :literalise_description?

      def self.rdf_type
        RDF::URI.new('http://www.example.org/rdf/type')
      end

      def uuid
        SecureRandom.uuid
      end

      def literalise_description?
        false
      end
    end
  end

  let(:model_instance) { model_class.new }

  describe '#literalise_rdf_graph!' do
    it 'is called by graph callback' do
      expect(model_instance).to receive(:literalise_rdf_graph!)
      model_instance.graph
    end

    context 'with non-sparse graph' do
      let(:model_instance) { model_class.new(dc_title: 'My Title', dc_description: 'My description') }

      it 'is not literalised' do
        model_instance.graph
        expect(model_instance.rdf_graph).not_to be_a(RDF::Literal)
      end
    end

    context 'with sparse graph' do
      let(:model_instance) { model_class.new(dc_title: 'My Title') }

      it 'is literalised' do
        model_instance.graph
        expect(model_instance.rdf_graph).to be_a(RDF::Literal)
        expect(model_instance.rdf_graph.value).to eq('My Title')
      end

      context 'on conditional callback' do
        let(:model_instance) { model_class.new(dc_description: 'My description') }

        it 'checks callback conditions' do
          allow(model_instance).to receive(:literalise_description?) { true }
          model_instance.graph
          expect(model_instance.rdf_graph).to be_a(RDF::Literal)
          expect(model_instance.rdf_graph.value).to eq('My description')
        end
      end
    end
  end
end
