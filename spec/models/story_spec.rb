# frozen_string_literal: true

require 'aasm/rspec'

RSpec.describe Story do
  subject { create(:story) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:ore_aggregation).of_type(ORE::Aggregation).
        as_inverse_of(:story).with_autobuild.with_dependent(:destroy)
    }
    it {
      is_expected.to belong_to(:created_by).of_type(User).
        as_inverse_of(:stories).with_dependent(nil)
    }
    it { is_expected.to accept_nested_attributes_for(:ore_aggregation) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(ore_aggregation: 1) }
    it { is_expected.to have_index_for(created_by: 1) }
    it { is_expected.to have_index_for(created_at: 1) }
    it { is_expected.to have_index_for(updated_at: 1) }
    it { is_expected.to have_index_for(aasm_state: 1) }
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

  describe 'AASM' do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:published).on_event(:publish) }
    it { is_expected.to transition_from(:published).to(:draft).on_event(:unpublish) }
    it { is_expected.to transition_from(:draft).to(:deleted).on_event(:wipe) }
  end
end
