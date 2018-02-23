# frozen_string_literal: true

RSpec.describe EDM::Agent do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDFModel) }
  end

  describe 'relations' do
    it {
      is_expected.to have_one(:dc_creator_agent_for_edm_web_resource).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dc_creator_agent).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:dc_contributor_agent_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dc_contributor_agent).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:dc_subject_agent_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dc_subject_agents).with_dependent(nil)
    }
  end
end
