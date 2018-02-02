# frozen_string_literal: true

RSpec.describe ThumbnailJob do
  let(:aggregation) { build(:ore_aggregation) }

  context 'for edm_isShownBy' do
    it 'uploads 200x200 and 400x400 thumbnails' do
      aggregation.save
      subject.perform(aggregation.edm_isShownBy.id, 'edm_isShownBy')
      media = aggregation.edm_isShownBy.media
      media.retrieve_from_store!('thumbnail-200x200.png')
      expect(media.file).to exist
      media.retrieve_from_store!('thumbnail-400x400.png')
      expect(media.file).to exist
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
      media.retrieve_from_store!('thumbnail-200x200.png')
      expect(media.file).to exist
      media.retrieve_from_store!('thumbnail-400x400.png')
      expect(media.file).to exist
    end
  end
end
