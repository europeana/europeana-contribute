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

  describe '#rdf_uri_or_literal' do
    subject { model_class.new.rdf_uri_or_literal(value, language: language) }

    context 'with language' do
      let(:language) { :en }
      let(:value) { 'Title' }

      it 'returns language-tagged RDF::Literal' do
        expect(subject).to eq(RDF::Literal.new(value, language: language))
      end
    end

    context 'without language' do
      let(:language) { nil }

      context 'when value responds to #rdf_uri' do
        let(:value) do
          Object.new.tap do |object|
            def object.rdf_uri
              RDF::URI.new('http://example.org/object/123')
            end
          end
        end

        it "returns value's #rdf_uri" do
          expect(subject).to eq(value.rdf_uri)
        end
      end

      context 'when value is "http://example.org/object/123"' do
        let(:value) { 'http://example.org/object/123' }
        it { is_expected.to eq(RDF::URI.new('http://example.org/object/123')) }
      end

      context 'when value is "true"' do
        let(:value) { 'true' }
        it { is_expected.to be('true') }
      end

      context 'when value is "hi :)"' do
        let(:value) { 'hi :)' }
        it { is_expected.to be('hi :)') }
      end
    end
  end
end
