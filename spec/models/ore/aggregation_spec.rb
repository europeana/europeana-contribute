# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe ORE::Aggregation do
  subject { create(:ore_aggregation) }

  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.not_to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid::Attributes) }
    it { is_expected.to include(Blankness::Mongoid::Relations) }
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
      is_expected.to belong_to(:edm_isShownBy).of_type(EDM::WebResource).
        as_inverse_of(:edm_isShownBy_for).with_dependent(:destroy)
    }
    it {
      is_expected.to have_and_belong_to_many(:edm_hasViews).of_type(EDM::WebResource).
        as_inverse_of(:edm_hasView_for).with_dependent(:destroy)
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
    it { is_expected.to have_index_for(edm_hasView_ids: 1) }
    it { is_expected.to have_index_for(edm_isShownBy_id: 1) }
    it { is_expected.to have_index_for(edm_provider: 1) }
    it { is_expected.to have_index_for(updated_at: 1) }
  end

  describe '#edm_web_resources' do
    before do
      subject.edm_isShownBy = create(:edm_web_resource)
      subject.edm_hasViews = [create(:edm_web_resource), create(:edm_web_resource)]
    end

    it 'includes edm:isShownBy' do
      expect(subject.edm_web_resources).to include(subject.edm_isShownBy)
    end

    it 'includes edm:hasViews' do
      subject.edm_hasViews.each do |hasView|
        expect(subject.edm_web_resources).to include(hasView)
      end
    end

    it 'responds to #klass' do
      expect(subject.edm_web_resources.klass).to eq(EDM::WebResource)
    end
  end

  describe 'edm_web_resources_attributes=' do
    let(:is_shown_by) { create(:edm_web_resource) }
    let(:has_view) { create(:edm_web_resource) }
    let(:attributes) do
      {
        '1' => {
          id: has_view.id.to_s,
          dc_description: ['New description for isShownBy']
        },
        '0' => {
          id: is_shown_by.id.to_s,
          dc_description: ['New description for hasView']
        }
      }
    end

    before do
      subject.edm_isShownBy = is_shown_by
      subject.edm_hasViews = [has_view]
    end

    it 'sets isShownBy attributes from the first' do
      subject.edm_web_resources_attributes=(attributes)
      expect(subject.edm_isShownBy.dc_description).to eq(['New description for isShownBy'])
    end

    it 'sets hasView attributes from the others' do
      subject.edm_web_resources_attributes=(attributes)
      expect(subject.edm_hasViews.first.dc_description).to eq(['New description for hasView'])
    end

    it 'updates foreign keys' do
      subject.edm_web_resources_attributes=(attributes)
      expect(subject.edm_isShownBy_id).to eq(has_view.id)
      expect(subject.edm_hasView_ids).to eq([is_shown_by.id])
    end
  end

  describe '#rdf_uri' do
    let(:aggregation) { build(:ore_aggregation) }
    subject { aggregation.rdf_uri }

    it 'uses CHO URI + #aggregation' do
      expect(subject).to eq(RDF::URI.new("#{aggregation.edm_aggregatedCHO.rdf_uri}#aggregation"))
    end
  end
end
