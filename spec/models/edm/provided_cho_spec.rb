# frozen_string_literal: true

RSpec.describe EDM::ProvidedCHO do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(RDFModel) }
    it { is_expected.to include(RemoveBlankAttributes) }
  end

  describe '.omitted_blank_associations' do
    subject { described_class.omitted_blank_associations }
    it { is_expected.to eq(%i(dc_subject_agents dc_contributor)) }
  end
end
