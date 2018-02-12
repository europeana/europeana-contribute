# frozen_string_literal: true

RSpec.describe Story do
  subject { create(:story) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
  end

  it 'should autobuild ore_aggregation' do
    expect(subject.ore_aggregation).not_to be_nil
  end

  describe '#sets' do
    let(:ore_aggregation) { build(:ore_aggregation, edm_provider: 'Provider') }
    subject { create(:story, ore_aggregation: ore_aggregation).sets }

    it 'returns the OAI-PMH set for edm_provider' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eq(1)
      expect(subject.first).to be_a(OAI::Set)
      expect(subject.first.name).to eq('Provider')
    end
  end

  describe '#to_oai_edm' do
    subject { create(:story).to_oai_edm }

    it 'returns RDF/XML without XML instruction' do
      expect(subject).to be_a(String)
      expect(subject).to start_with('<rdf:RDF')
    end

    context 'with contributor name and email' do
      subject do
        aggregation = build(:ore_aggregation)
        aggregation.build_edm_aggregatedCHO
        aggregation.edm_aggregatedCHO.dc_contributor_agent = build(:edm_agent, foaf_name: 'My name', foaf_mbox: 'me@example.org', skos_prefLabel: 'Me' )
        story = build(:story)
        story.ore_aggregation = aggregation
        story.to_oai_edm
      end

      it 'removes them' do
        expect(subject).not_to include('<foaf:name>My name</foaf:name>')
        expect(subject).not_to include('<foaf:mbox>me@example.org</foaf:mbox>')
        expect(subject).to include('<skos:prefLabel>Me</skos:prefLabel>')
      end
    end
  end
end
