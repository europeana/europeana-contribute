# frozen_string_literal: true

require 'support/shared_examples/models/rdf_uuid_urn'

RSpec.describe EDM::Agent do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(Blankness::Mongoid::Attributes) }
    it { is_expected.to include(Blankness::Mongoid::Relations) }
    it { is_expected.to include(RDF::Graphable) }
  end

  describe 'relations' do
    it {
      is_expected.to have_one(:dc_creator_agent_for_edm_web_resource).of_type(EDM::WebResource).
        as_inverse_of(:dc_creator_agent).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:dc_contributor_agent_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dc_contributor_agent).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:dc_subject_agent_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dc_subject_agents).with_dependent(nil)
    }
  end

  let(:agent) { build(:edm_agent) }

  context 'when it has a CHO' do
    subject { agent.rdf_uri }
    let(:cho) { build(:edm_provided_cho) }
    before do
      allow(agent).to receive(:edm_provided_cho) { cho }
    end
    describe '#rdf_uri' do
      it %(is CHO's URI + "#agent-" + agent's UUID) do
        expect(subject).to eq(cho.rdf_uri + '#agent-' + agent.uuid)
      end
    end
  end

  context 'when it has no CHO' do
    subject { agent }
    before do
      allow(agent).to receive(:edm_provided_cho) { nil }
    end
    it_behaves_like 'RDF UUID URN'
  end
end
