# frozen_string_literal: true

RSpec.describe CC::License do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
  end

  describe 'relations' do
    it {
      is_expected.to have_many(:edm_rights_for_edm_web_resources).of_type(EDM::WebResource).
        as_inverse_of(:edm_rights).with_dependent(:restrict)
    }
    it {
      is_expected.to have_many(:edm_rights_for_ore_aggregations).of_type(ORE::Aggregation).
        as_inverse_of(:edm_rights).with_dependent(:restrict)
    }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(rdf_about: 1).with_options(unique: true) }
  end
end
