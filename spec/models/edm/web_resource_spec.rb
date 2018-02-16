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

  describe 'thumbnail generation after media edit' do
    let(:wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }

    context 'when the webresource is created' do
      context 'when it is an edm_isShownBy' do
        it 'is expected to queue a thumbnail job' do
          expect(ActiveJob::Base.queue_adapter).to receive(:enqueue).with(ThumbnailJob)
          described_class.create(media: wr_media)
        end
      end
    end

    context 'when the web_resource already exists' do
      let(:web_resource) { described_class.create(media: wr_media) }
      before do
        web_resource
      end

      context 'when the media has NOT been updated' do
        it 'is expected to not queue a thumbnail job' do
          expect(ActiveJob::Base.queue_adapter).to_not receive(:enqueue).with(ThumbnailJob)
          web_resource.save
        end
      end

      context 'when the media has been updated' do
        let(:new_wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }
        it 'is expected to queue a thumbnail job' do
          web_resource.media = new_wr_media
          expect(ActiveJob::Base.queue_adapter).to receive(:enqueue).with(ThumbnailJob)
          web_resource.save
        end
      end
    end
  end
end
