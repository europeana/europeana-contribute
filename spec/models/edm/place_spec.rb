# frozen_string_literal: true

RSpec.describe EDM::Place do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Graphable) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:dcterms_spatial_place_for).of_type(EDM::ProvidedCHO).
        as_inverse_of(:dcterms_spatial_places).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:edm_happenedAt_for).of_type(EDM::Event).
        as_inverse_of(:edm_happenedAt).with_dependent(nil)
    }
  end
end
