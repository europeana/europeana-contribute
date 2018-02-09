# frozen_string_literal: true

RSpec.describe ThumbnailJob do
  let(:web_resource) { build(:edm_web_resource) }

  it { is_expected.to be_processed_in :thumbnails }

  context 'for edm_isShownBy' do
    before do
      web_resource.save # persist the edm_web_resource
    end
    after do
      web_resource.delete
    end
    context 'for an image file' do
      it 'uploads 200x200 and 400x400 thumbnails' do
        subject.perform(web_resource.id)
        media = web_resource.media
        media.retrieve_from_store!('image.jpg') # reload the stored versions
        expect(media.thumb_200x200.file).to exist
        expect(media.thumb_400x400.file).to exist
      end
    end

    context 'for a non-image file' do
      let(:wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'audio.mp3'), 'audio/mp3') }
      let(:web_resource) {  build(:edm_web_resource, media: wr_media) }

      it 'does NOT upload thumbnails' do
        subject.perform(web_resource.id)
        media = web_resource.media
        media.retrieve_from_store!('audio.mp3') # reload the stored versions
        expect(media.thumb_200x200.file).to_not be_present
        expect(media.thumb_400x400.file).to_not be_present
      end
    end
  end
end
