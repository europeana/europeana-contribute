# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::ProvidedCHO do
  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(CampaignValidatableModel) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Graphable) }

    it { is_expected.to reject_if_blank(:dc_contributor_agent) }
    it { is_expected.to reject_if_blank(:dc_subject_agents) }
    it { is_expected.to reject_if_blank(:dcterms_spatial_places) }
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
      is_expected.to have_many(:dc_subject_agents).of_type(EDM::Agent).
        as_inverse_of(:dc_subject_agent_for).with_dependent(:destroy)
    }
    it {
      is_expected.to have_and_belong_to_many(:dcterms_spatial_places).of_type(EDM::Place).
        as_inverse_of(nil).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:edm_aggregatedCHO_for).of_type(ORE::Aggregation).
        as_inverse_of(:edm_aggregatedCHO).with_dependent(nil)
    }
    it { is_expected.to accept_nested_attributes_for(:dc_subject_agents) }
    it { is_expected.to accept_nested_attributes_for(:dc_contributor_agent) }
    it { is_expected.to accept_nested_attributes_for(:dcterms_spatial_places) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(edm_wasPresentAt: 1) }
  end

  describe '#rdf_uri' do
    let(:uuid) { SecureRandom.uuid }
    let(:cho) { described_class.new(uuid: uuid) }
    subject { cho.rdf_uri }

    it 'uses base URL, /contributions and UUID' do
      expect(subject).to eq(RDF::URI.new("#{Rails.configuration.x.base_url}/contributions/#{uuid}"))
    end
  end
end
