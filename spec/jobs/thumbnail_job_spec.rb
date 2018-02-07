# frozen_string_literal: true

RSpec.describe ThumbnailJob do
  let(:aggregation) { build(:ore_aggregation) }

  it { is_expected.to be_processed_in :thumbnails }

  context 'for edm_isShownBy' do
    context 'for an image file' do
      it 'uploads 200x200 and 400x400 thumbnails' do
        aggregation.save
        subject.perform(aggregation.edm_isShownBy.id, 'edm_isShownBy')
        media = aggregation.edm_isShownBy.media
        media.retrieve_from_store!('image.jpg') # reload the stored versions
        expect(media.thumb_200x200.file).to exist
        expect(media.thumb_400x400.file).to exist
      end
    end

    context 'for a non-image file' do
      let(:wr_media) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'audio.mp3'), 'audio/mp3') }
      let(:wr) {  build(:edm_web_resource, media: wr_media) }
      let(:aggregation) { build(:ore_aggregation, edm_isShownBy: wr) }
      it 'does NOT upload thumbnails' do
        aggregation.save
        subject.perform(aggregation.edm_isShownBy.id, 'edm_isShownBy')
        media = aggregation.edm_isShownBy.media
        media.retrieve_from_store!('audio.mp3') # reload the stored versions
        expect(media.thumb_200x200.file).to_not be_present
        expect(media.thumb_400x400.file).to_not be_present
      end
    end
  end

  context 'for edm_hasView' do
    before do
      aggregation.save
      aggregation.edm_hasViews << build(:edm_web_resource)
      aggregation.save
    end
    it 'uploads 200x200 and 400x400 thumbnails' do
      subject.perform(aggregation.edm_hasViews.first.id, 'edm_hasViews')
      media = aggregation.edm_hasViews.first.media
      media.retrieve_from_store!('image.jpg') # reload the stored versions
      expect(media.thumb_200x200.file).to exist
      expect(media.thumb_400x400.file).to exist
    end
  end
end
