# frozen_string_literal: true

RSpec.describe EDM::Agent do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Model) }
  end
end
