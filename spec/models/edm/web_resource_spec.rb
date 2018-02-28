# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::WebResource do
  describe 'class' do
    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Graphable) }

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
      is_expected.to belong_to(:edm_hasView_for).of_type(ORE::Aggregation).
        as_inverse_of(:edm_hasViews).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:edm_isShownBy_for).of_type(ORE::Aggregation).
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

    context 'when the file is of type image(jpeg)' do
      let(:mime_type) { 'image/jpeg' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type image(bmp)' do
      let(:mime_type) { 'image/x-ms-bmp' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type image(tiff)' do
      let(:mime_type) { 'image/tiff' }
      it { is_expected.to be_valid }
    end

    context 'when the file is of type image(gif)' do
      let(:mime_type) { 'image/gif' }
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

  describe 'invalid media removal after validation' do
    let(:edm_web_resource) do
      build(:edm_web_resource).tap do |wr|
        allow(wr.media).to receive(:content_type) { mime_type }
      end
    end

    context 'when the mimetype is invalid' do
      let(:mime_type) { 'image/jpeg' }
      it 'should call remove_media!' do
        expect(edm_web_resource).to_not receive(:remove_media!)
        edm_web_resource.validate
      end
    end

    context 'when the mimetype is invalid' do
      let(:mime_type) { 'video/x-ms-wmv' }
      it 'should call remove_media!' do
        expect(edm_web_resource).to receive(:remove_media!)
        edm_web_resource.validate
      end
    end
  end

  describe '#ore_aggregation' do
    let(:edm_web_resource) { create(:edm_web_resource) }

    context 'when edm_isShownBy_for is present' do
      let(:ore_aggregation) { create(:ore_aggregation, edm_isShownBy: edm_web_resource) }
      it 'is edm_isShownBy_for' do
        expect(ore_aggregation).to be_persisted
        expect(edm_web_resource.edm_isShownBy_for).to eq(ore_aggregation)
        expect(edm_web_resource.ore_aggregation).to eq(ore_aggregation)
      end
    end

    context 'when edm_isShownBy_for is absent' do
      context 'but edm_hasView_for is present' do
        let(:ore_aggregation) { create(:ore_aggregation, edm_hasViews: [edm_web_resource]) }
        it 'is edm_hasView_for' do
          expect(ore_aggregation).to be_persisted
          expect(edm_web_resource.edm_hasView_for).to eq(ore_aggregation)
          expect(edm_web_resource.ore_aggregation).to eq(ore_aggregation)
        end
      end
    end
  end

  describe '#rdf_uri' do
    let(:uuid) { SecureRandom.uuid }
    subject { described_class.new(uuid: uuid).rdf_uri }

    it 'uses base URL, /media and UUID' do
      expect(subject).to eq(RDF::URI.new("#{Rails.configuration.x.base_url}/media/#{uuid}"))
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
