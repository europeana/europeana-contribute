# frozen_string_literal: true

require 'aasm/rspec'

RSpec.describe Contribution do
  subject { create(:contribution) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(RDF::Dumpable) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:campaign).of_type(Campaign).
        as_inverse_of(:contributions).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:created_by).of_type(User).
        as_inverse_of(:contributions).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:ore_aggregation).of_type(ORE::Aggregation).
        as_inverse_of(:contribution).with_autobuild.with_dependent(:destroy)
    }
    it { is_expected.to accept_nested_attributes_for(:ore_aggregation) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(aasm_state: 1) }
    it { is_expected.to have_index_for(campaign: 1) }
    it { is_expected.to have_index_for(created_at: 1) }
    it { is_expected.to have_index_for(created_by: 1) }
    it { is_expected.to have_index_for(first_published_at: 1) }
    it { is_expected.to have_index_for(ore_aggregation: 1) }
    it { is_expected.to have_index_for(updated_at: 1) }
  end

  it 'should autobuild ore_aggregation' do
    expect(subject.ore_aggregation).not_to be_nil
  end

  describe '#sets' do
    let(:ore_aggregation) { build(:ore_aggregation, edm_provider: 'Provider') }
    subject { create(:contribution, ore_aggregation: ore_aggregation).sets }

    it 'returns the OAI-PMH set for edm_provider' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eq(1)
      expect(subject.first).to be_a(OAI::Set)
      expect(subject.first.name).to eq('Provider')
    end
  end

  describe '#to_oai_edm' do
    subject { create(:contribution).to_oai_edm }

    it 'returns RDF/XML without XML instruction' do
      expect(subject).to be_a(String)
      expect(subject).to start_with('<rdf:RDF')
    end

    context 'with contributor name and email' do
      subject do
        aggregation = build(:ore_aggregation)
        aggregation.build_edm_aggregatedCHO
        aggregation.edm_aggregatedCHO.dc_contributor_agent = build(:edm_agent, foaf_name: ['My name'], foaf_mbox: ['me@example.org'], skos_prefLabel: 'Me')
        contribution = build(:contribution)
        contribution.ore_aggregation = aggregation
        contribution.to_oai_edm
      end

      it 'removes them' do
        expect(subject).not_to include('<foaf:name>My name</foaf:name>')
        expect(subject).not_to include('<foaf:mbox>me@example.org</foaf:mbox>')
        expect(subject).to include('<dc:contributor>Me</dc:contributor>')
      end
    end
  end

  describe 'AASM' do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:published).on_event(:publish) }
    it { is_expected.to transition_from(:published).to(:draft).on_event(:unpublish) }
    it { is_expected.to transition_from(:draft).to(:deleted).on_event(:wipe) }

    describe 'publish event' do
      context 'without first_published_at' do
        let(:contribution) { build(:contribution) }
        it 'sets it' do
          expect { contribution.publish }.to change { contribution.first_published_at }.from(nil)
        end
      end

      context 'with first_published_at' do
        let(:contribution) { build(:contribution, first_published_at: Time.zone.now - 1.day) }
        it 'does not change it' do
          expect { contribution.publish }.not_to change { contribution.first_published_at }
        end
      end
    end
  end
end
