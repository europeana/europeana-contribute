# frozen_string_literal: true

RSpec.describe ThumbnailJob do
  it { is_expected.to be_processed_in :thumbnails }

  context 'for an image file' do
    let(:web_resource) { create(:edm_web_resource) }

    it 'generates w200 and w400 thumbnails' do
      media = web_resource.media
      media.retrieve_from_store!(media.filename) # reload the stored versions
      expect(media.w200.file).to_not exist
      expect(media.w400.file).to_not exist
      subject.perform(web_resource.id.to_s)
      expect(media.w200.file).to exist
      expect(media.w400.file).to exist
    end
  end

  context 'for a non-image file' do
    let(:web_resource) { create(:edm_web_resource, :audio_media) }

    it 'does NOT generate thumbnails' do
      subject.perform(web_resource.id.to_s)
      media = web_resource.media
      media.retrieve_from_store!('audio.mp3') # reload the stored versions
      expect(media.w200.file).to_not be_present
      expect(media.w400.file).to_not be_present
    end
  end
end
