# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe ORE::Aggregation do
  subject { create(:ore_aggregation) }

  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.not_to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Graphable) }

    it { is_expected.to reject_if_blank(:edm_isShownBy) }
    it { is_expected.to reject_if_blank(:edm_hasViews) }
  end

  it 'should autobuild edm_aggregatedCHO' do
    expect(subject.edm_aggregatedCHO).to be_a(EDM::ProvidedCHO)
  end

  describe '#rdf_uri' do
    let(:uuid) { SecureRandom.uuid }
    subject { build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, uuid: uuid)).rdf_uri }

    it 'uses FQDN, /stories and UUID of aggregations' do
      expect(subject).to eq(RDF::URI.new("https://stories.europeana.eu/stories/#{uuid}"))
    end
  end
end
