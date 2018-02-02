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

  describe 'thumbnail generation after creation' do
    let(:creation_args) {
      {
        media: wr_media,
        edm_hasView_for: wr_edm_hasView_for,
        edm_isShownBy_for: wr_edm_isShownBy_for
      }
    }
    let(:wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }
    let(:wr_edm_isShownBy_for) { build(:ore_aggregation, edm_isShownBy: nil) }
    let(:wr_edm_hasView_for) { nil }

    context 'when the webresource has Image type media' do
      context 'when it is an edm_isShownBy' do
        it 'is expected to queue a thumbnail job' do
          expect{ described_class.create(creation_args) }.to enqueue_job(ThumbnailJob).with(an_instance_of(String), 'edm_isShownBy')
        end
      end

      context 'when it is an edm_hasView' do
        let(:wr_edm_isShownBy_for) { nil }
        let(:wr_edm_hasView_for) { build(:ore_aggregation, edm_isShownBy: nil) }
        it 'is expected to queue a thumbnail job' do
          expect{ described_class.create(creation_args) }.to enqueue_job(ThumbnailJob).with(an_instance_of(String), 'edm_hasViews')
        end
      end
    end

    context 'when the webresource does NOT have Image type media' do
      let(:wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'audio.mp3'), 'audio/mp3') }
      it 'is expected to not queue a thumbnail job' do
        expect{ described_class.create(creation_args) }.to_not enqueue_job(ThumbnailJob)
      end
    end
  end
end
