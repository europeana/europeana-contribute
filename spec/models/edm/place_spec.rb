# frozen_string_literal: true

require 'support/shared_examples/models/rdf_uuid_urn'

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
      is_expected.to have_one(:edm_happenedAt_for).of_type(EDM::Event).
        as_inverse_of(:edm_happenedAt).with_dependent(nil)
    }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(rdf_about: 1) }
  end

  subject { build(:edm_place) }

  it_behaves_like 'RDF UUID URN'

  context 'with rdf_about' do
    let(:rdf_about) { 'http://www.example.org/place/123' }

    describe '#rdf_uri' do
      subject { build(:edm_place, rdf_about: rdf_about).rdf_uri }

      it 'is expected to use rdf_about' do
        expect(subject).to eq(rdf_about)
      end
    end
  end
end
