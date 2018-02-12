# frozen_string_literal: true

RSpec.describe EDM::Place do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDFModel) }
  end
end
