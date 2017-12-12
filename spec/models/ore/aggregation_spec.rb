# frozen_string_literal: true

RSpec.describe ORE::Aggregation do
  subject { create(:ore_aggregation) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(RDFModel) }
    it { is_expected.to include(RemoveBlankAttributes) }
  end

  it 'should autobuild edm_aggregatedCHO' do
    expect(subject.edm_aggregatedCHO).not_to be_nil
  end

  describe '#sets' do
    subject { create(:ore_aggregation, edm_provider: 'Provider').sets }

    it 'returns the OAI-PMH set for edm_provider' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eq(1)
      expect(subject.first).to be_a(OAI::Set)
      expect(subject.first.name).to eq('Provider')
    end
  end

  describe '#to_oai_edm' do
    subject { create(:ore_aggregation).to_oai_edm }

    it 'returns RDF/XML without XML instruction' do
      expect(subject).to be_a(String)
      expect(subject).to start_with('<rdf:RDF')
    end
  end
end
