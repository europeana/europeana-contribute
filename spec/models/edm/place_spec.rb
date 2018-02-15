# frozen_string_literal: true

RSpec.describe EDM::Place do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDFModel) }
  end

  describe 'relations' do
    it {
      is_expected.to have_one(:dcterms_spatial_place_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dcterms_spatial_places).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:edm_happenedAt_for).of_type(EDM::Event).
        as_inverse_of(:edm_happenedAt).with_dependent(nil)
    }
  end
end
