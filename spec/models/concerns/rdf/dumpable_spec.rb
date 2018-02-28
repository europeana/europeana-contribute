# frozen_string_literal: true

RSpec.describe RDF::Dumpable do
  let(:model_instance) { model_class.new }

  context 'without to_rdf' do
    let(:model_class) do
      Class.new do
        include RDF::Dumpable
      end
    end

    %w(to_jsonld to_turtle to_ntriples to_rdfxml to_oai_edm).each do |meth|
      describe "##{meth}" do
        it 'fails' do
          expect { model_instance.send(meth) }.to raise_exception(/to_rdf/)
        end
      end
    end
  end

  context 'with to_rdf' do
    let(:model_class) do
      Class.new do
        include RDF::Dumpable
        def to_rdf
          RDF::Graph.new do |graph|
            graph << [RDF::URI.new('http://www.example.org/person/me'), RDF::Vocab::FOAF.name, 'My Name']
            graph << [RDF::URI.new('http://www.example.org/person/me'), RDF::Vocab::DC11.description, 'I like RDF.']
          end
        end
      end
    end

    describe '#to_jsonld' do
      subject { model_instance.to_jsonld }
      it 'should include subject ID' do
        expect(subject).to include('"@id": "http://www.example.org/person/me"')
      end
      it 'should include RDF statements' do
        expect(subject).to include('"dc:description": "I like RDF."')
        expect(subject).to include('"foaf:name": "My Name"')
      end
      it 'should be parseable JSON' do
        expect { JSON.parse(subject) }.not_to raise_exception
      end
    end

    describe '#to_turtle' do
      subject { model_instance.to_turtle }
      it 'should include subject ID' do
        expect(subject).to include('<http://www.example.org/person/me>')
      end
      it 'should include RDF statements' do
        expect(subject).to include('dc:description "I like RDF."')
        expect(subject).to include('foaf:name "My Name"')
      end
    end

    describe '#to_ntriples' do
      subject { model_instance.to_ntriples }
      it 'should include RDF N-triples' do
        expect(subject).to include('<http://www.example.org/person/me> <http://purl.org/dc/elements/1.1/description> "I like RDF."')
        expect(subject).to include('<http://www.example.org/person/me> <http://xmlns.com/foaf/0.1/name> "My Name"')
      end
    end

    describe '#to_rdfxml' do
      subject { model_instance.to_rdfxml }
      it 'includes XML instruction' do
        expect(subject).to start_with('<?xml')
      end
      it 'should include subject ID' do
        expect(subject).to include('<rdf:Description rdf:about="http://www.example.org/person/me">')
      end
      it 'should include RDF statements' do
        expect(subject).to include('<dc:description>I like RDF.</dc:description>')
        expect(subject).to include('<foaf:name>My Name</foaf:name>')
      end
      it 'should be parseable XML' do
        expect { Nokogiri::XML.parse(subject) }.not_to raise_exception
      end
    end

    describe '#to_oai_edm' do
      subject { model_instance.to_oai_edm }
      it 'strips XML instruction from RDF/XML' do
        expect(subject).to start_with('<rdf:RDF')
      end
    end
  end
end
