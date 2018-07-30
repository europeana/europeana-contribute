# frozen_string_literal: true

RSpec.describe RDF::Graphable::Literalisation do
  let(:base_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Literalisation

      def self.rdf_type
        RDF::URI.new('http://www.example.org/rdf/type')
      end

      def uuid
        SecureRandom.uuid
      end
    end
  end

  let(:model_instance) { model_class.new }

  describe '#untype_rdf_literals!' do
    context 'without graphs_rdf_literals_untyped called on class' do
      let(:model_class) do
        Class.new(base_class) do
          field :dcterms_created, type: Date
        end
      end

      it 'is not called by graph callback' do
        expect(model_instance).not_to receive(:untype_rdf_literals!)
        model_instance.graph
      end

      it 'does not remove typing from literals' do
        model_instance.dcterms_created = Date.today
        literal = model_instance.graph.query(predicate: RDF::Vocab::DC.created).first.object
        expect(literal).to be_typed
      end
    end

    context 'with graphs_rdf_literals_untyped called on class' do
      let(:model_class) do
        Class.new(base_class) do
          field :dcterms_created, type: Date

          graphs_rdf_literals_untyped
        end
      end

      it 'is called by graph callback' do
        expect(model_instance).to receive(:untype_rdf_literals!)
        model_instance.graph
      end

      it 'removes typing from literals' do
        model_instance.dcterms_created = Date.today
        literal = model_instance.graph.query(predicate: RDF::Vocab::DC.created).first.object
        expect(literal).not_to be_typed
      end
    end
  end

  describe '#literalise_rdf_graph!' do
    let(:model_class) do
      Class.new(base_class) do
        field :dc_title, type: String
        field :dc_description, type: String

        graphs_as_literal RDF::Vocab::DC11.title
        graphs_as_literal RDF::Vocab::DC11.description, if: :literalise_description?

        def literalise_description?
          false
        end
      end
    end

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
