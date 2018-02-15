# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::WebResource do
  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDFModel) }

    it { is_expected.to reject_if_blank(:dc_creator_agent) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:edm_rights).of_type(CC::License).
        as_inverse_of(:edm_rights_for_edm_web_resources).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:dc_creator_agent).of_type(EDM::Agent).
        as_inverse_of(:dc_creator_agent_for_edm_web_resource).with_dependent(:destroy)
    }
    it {
      is_expected.to have_one(:edm_hasView_for).of_type(ORE::Aggregation).
        as_inverse_of(:edm_hasViews).with_dependent(nil)
    }
    it {
      is_expected.to have_one(:edm_isShownBy_for).of_type(ORE::Aggregation).
        as_inverse_of(:edm_isShownBy).with_dependent(nil)
    }
    it { is_expected.to accept_nested_attributes_for(:dc_creator_agent) }
  end

  describe '.allowed_extensions' do
    subject { described_class.allowed_extensions }
    it { is_expected.to match(/\.jpg/) }
    it { is_expected.to match(/\.png/) }
    it { is_expected.to match(/\.mp3/) }
    it { is_expected.to match(/\.webm/) }
    it { is_expected.to_not match(/\.exe/) }
    it { is_expected.to_not match(/\.sh/) }
    it { is_expected.to_not match(/\.virus/) }
  end


  describe '.allowed_content_types' do
    subject { described_class.allowed_content_types }
    it { is_expected.to match(%r(image/jpeg)) }
    it { is_expected.to match(%r(video/webm)) }
    it { is_expected.to match(%r(audio/mp3)) }
    it { is_expected.to match(%r(application/pdf)) }
    it { is_expected.to_not match(%r(application/applefile)) }
    it { is_expected.to_not match(%r(application/geo+json)) }
    it { is_expected.to_not match(%r(text/xml)) }
  end

  describe 'mimetype validation' do
    let(:edm_web_resource) do
      build(:edm_web_resource).tap do |wr|
        allow(wr.media).to receive(:content_type) { mime_type }
      end
    end

    subject { edm_web_resource }

    context 'when the file is of type image' do
      let(:mime_type) { 'image/jpeg' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type audio' do
      let(:mime_type) { 'audio/mp3' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type video' do
      let(:mime_type) { 'video/webm' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type pdf text' do
      let(:mime_type) { 'application/pdf' }
      it { is_expected.to be_valid }
    end

    context 'when the file type is not supported' do
      let(:mime_type) { 'video/x-ms-wmv' }
      it { is_expected.to_not be_valid }
    end
  end
end
