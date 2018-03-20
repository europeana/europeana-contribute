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

  describe 'relations' do
    it {
      is_expected.to belong_to(:edm_aggregatedCHO).of_type(EDM::ProvidedCHO).
        with_autobuild.as_inverse_of(:edm_aggregatedCHO_for).with_dependent(:destroy)
    }
    it {
      is_expected.to belong_to(:edm_rights).of_type(CC::License).
        as_inverse_of(:edm_rights_for_ore_aggregations).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:edm_isShownBy).of_type(EDM::WebResource).
        as_inverse_of(:edm_isShownBy_for)
    }
    it {
      is_expected.to have_many(:edm_hasViews).of_type(EDM::WebResource).
        as_inverse_of(:edm_hasView_for)
    }
    it {
      is_expected.to have_one(:contribution).of_type(Contribution).
        as_inverse_of(:ore_aggregation).with_dependent(nil)
    }
    it { is_expected.to accept_nested_attributes_for(:edm_aggregatedCHO) }
    it { is_expected.to accept_nested_attributes_for(:edm_isShownBy) }
    it { is_expected.to accept_nested_attributes_for(:edm_hasViews) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(created_at: 1) }
    it { is_expected.to have_index_for(edm_aggregatedCHO: 1) }
    it { is_expected.to have_index_for(edm_dataProvider: 1) }
    it { is_expected.to have_index_for(edm_provider: 1) }
    it { is_expected.to have_index_for(updated_at: 1) }
  end

  describe '#rdf_uri' do
    let(:aggregation) { build(:ore_aggregation) }
    subject { aggregation.rdf_uri }

    it 'uses CHO URI + #aggregation' do
      expect(subject).to eq(RDF::URI.new("#{aggregation.edm_aggregatedCHO.rdf_uri}#aggregation"))
    end
  end

  describe 'destruction' do
    it 'should wipe all related EDM::WebResources' do
      aggregation = create(:ore_aggregation)
      web_resources = aggregation.edm_web_resources
      aggregation.destroy
      web_resources.each do |wr|
        expect(EDM::WebResource.deleted.find(wr.id)).to_not be_nil
      end
    end
  end
end
