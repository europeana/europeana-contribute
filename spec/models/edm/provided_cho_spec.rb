# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::ProvidedCHO do
  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDFModel) }

    it { is_expected.to reject_if_blank(:dc_contributor_agent) }
    it { is_expected.to reject_if_blank(:dc_subject_agents) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:dc_contributor_agent).of_type(EDM::Agent).
        as_inverse_of(:dc_contributor_agent_for).with_dependent(:destroy)
    }
    it {
      is_expected.to belong_to(:edm_wasPresentAt).of_type(EDM::Event).
        as_inverse_of(:edm_wasPresentAt_for).with_dependent(nil)
    }
    it {
      is_expected.to have_and_belong_to_many(:dc_subject_agents).of_type(EDM::Agent).
        as_inverse_of(:dc_subject_agent_for).with_dependent(:destroy)
    }
    it {
      is_expected.to have_one(:edm_aggregatedCHO_for).of_type(ORE::Aggregation).
        as_inverse_of(:edm_aggregatedCHO).with_dependent(nil)
    }
    it { is_expected.to accept_nested_attributes_for(:dc_subject_agents) }
    it { is_expected.to accept_nested_attributes_for(:dc_contributor_agent) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(edm_wasPresentAt: 1) }
  end
end
