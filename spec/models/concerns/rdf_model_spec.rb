# frozen_string_literal: true

RSpec.describe RDFModel do
  let(:model_class) do
    Class.new do
      include RDFModel
    end
  end

  describe '.rdf_predicate_for_field' do
    context 'with overriden predicate' do
      let(:field_name) { :dc_title }
      let(:rdf_predicate) { RDF::URI.new('http://example.org/vocab/title') }

      before do
        model_class.has_rdf_predicate(field_name, rdf_predicate)
      end

      it 'uses overriden RDF predicate' do
        expect(model_class.rdf_predicate_for_field(field_name)).to eq(rdf_predicate)
      end
    end

    context 'without overriden predicate' do
      let(:field_name) { :dc_title }
      let(:rdf_predicate) { RDF::Vocab::DC11.title }

      it 'derives RDF predicate from field name' do
        expect(model_class.rdf_predicate_for_field(field_name)).to eq(rdf_predicate)
      end
    end
  end
end
