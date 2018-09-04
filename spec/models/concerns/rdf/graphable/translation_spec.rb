# frozen_string_literal: true

RSpec.describe RDF::Graphable::Translation do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include RDF::Graphable
      include RDF::Graphable::Translation

      def self.rdf_type
        RDF::URI.new('http://www.example.org/rdf/type')
      end

      def uuid
        SecureRandom.uuid
      end
    end
  end

  let(:model_instance) { model_class.new(attributes) }
  let(:attributes) { {} }

  describe '.graphs_translated' do
    context 'with "with" arg present' do
      before do
        model_class.field :foaf_name, type: String
        model_class.graphs_translated RDF::Vocab::FOAF.name,
                                      with: ->(value) { RDF::Literal.new(value.to_s.upcase) }
      end

      let(:attributes) { { foaf_name: Forgery::Name.full_name } }

      it 'translates with lambda' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).first.object).
          to eq(model_instance.foaf_name.upcase)
      end

      it 'replaces original statement' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count).to eq(1)
      end
    end

    context 'with "to" arg present' do
      before do
        model_class.field :dc_coverage, type: String
        model_class.graphs_translated RDF::Vocab::DC11.coverage,
                                      to: RDF::Vocab::DC.spatial
      end

      let(:attributes) { { dc_coverage: Forgery::Address.street_address } }

      it 'changes predicate' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::DC.spatial).first.object).
          to eq(model_instance.dc_coverage)
      end

      it 'replaces original statement' do
        model_instance.graph
        expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::DC11.coverage).count).to be_zero
      end
    end

    context 'with both "with" and "to" args present' do
        before do
          model_class.field :dc_coverage, type: String
          model_class.graphs_translated RDF::Vocab::DC11.coverage,
                                        to: RDF::Vocab::DC.spatial,
                                        with:->(value) { RDF::Literal.new(value.to_s.upcase) }
        end

        let(:attributes) { { dc_coverage: Forgery::Address.street_address } }

        it 'changes predicate and translates with lambda' do
          model_instance.graph
          expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::DC.spatial).first.object).
            to eq(model_instance.dc_coverage.upcase)
        end

        it 'replaces original statement' do
          model_instance.graph
          expect(model_instance.rdf_graph.query(predicate: RDF::Vocab::DC11.coverage).count).to be_zero
        end
      end
  end
end
