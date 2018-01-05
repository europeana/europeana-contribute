# frozen_string_literal: true

RSpec.describe EDM::WebResource do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(RDFModel) }
    it { is_expected.to include(RemoveBlankAttributes) }
  end

  describe 'mimetype validation' do
    let(:edm_web_resource) do
      build(:edm_web_resource).tap do |wr|
        allow(wr.media).to receive(:content_type) { mime_type }
      end
    end

    subject { edm_web_resource }

    context 'when the file is of type image' do
      let(:mime_type) { 'image/jpg' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type audio' do
      let(:mime_type) { 'audio/mp3' }
      it { is_expected.to be_valid }
    end

    context 'when the file type is not supported' do
      let(:mime_type) { 'application/pdf' }
      it { is_expected.to_not be_valid }
    end
  end
end
