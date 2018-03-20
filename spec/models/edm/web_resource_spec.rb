# frozen_string_literal: true

require 'aasm/rspec'
require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::WebResource do
  let(:image_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }

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

  describe 'indexes' do
    it { is_expected.to have_index_for(edm_isShownBy_for: 1) }
    it { is_expected.to have_index_for(edm_hasView_for: 1) }
    it { is_expected.to have_index_for(aasm_state: 1) }
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
    it { is_expected.to match(%r(image/bmp)) }
    it { is_expected.to match(%r(image/x-ms-bmp)) }
    it { is_expected.to match(%r(image/x-windows-bmp)) }
    it { is_expected.to match(%r(image/tiff)) }
    it { is_expected.to match(%r(image/gif)) }
    it { is_expected.to match(%r(image/png)) }

    it { is_expected.to match(%r(video/mp4)) }
    it { is_expected.to match(%r(video/webm)) }

    it { is_expected.to match(%r(audio/mp3)) }
    it { is_expected.to match(%r(audio/mpeg)) }
    it { is_expected.to match(%r(audio/mpeg3)) }
    it { is_expected.to match(%r(audio/x-mpeg-3)) }
    it { is_expected.to match(%r(audio/webm)) }
    it { is_expected.to match(%r(audio/wav)) }
    it { is_expected.to match(%r(audio/x-wav)) }

    it { is_expected.to match(%r(application/pdf)) }

    it { is_expected.to_not match(%r(application/applefile)) }
    it { is_expected.to_not match(%r(application/geo+json)) }
    it { is_expected.to_not match(%r(text/xml)) }
  end

  describe 'AASM' do
    it { is_expected.to have_state(:active) }
    it { is_expected.to transition_from(:active).to(:deleted).on_event(:wipe) }

    describe 'wipe event' do
      let(:web_resource) { build(:edm_web_resource) }
      it 'clears media and sets aasm state to deleted' do
        expect(web_resource).to receive(:remove_versions)
        expect(web_resource).to receive(:remove_media!)
        web_resource.wipe!
        expect(web_resource.aasm_state).to eq('deleted')
      end
    end
  end

  describe 'mime type validation' do
    let(:edm_web_resource) do
      build(:edm_web_resource).tap do |wr|
        allow(wr.media).to receive(:content_type) { mime_type }
      end
    end

    subject { edm_web_resource }

    EDM::WebResource::ALLOWED_CONTENT_TYPES.each do |content_type|
      context "when the file is of type #{content_type}" do
        let(:mime_type) { content_type }
        it { is_expected.to be_valid }
      end
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
        allow(wr.media).to receive(:file) { file }
      end
    end
    let(:file) { double('fake_file', size: 4000000) }
    before do
      allow(file).to receive(:content_type) { mime_type }
    end

    context 'when the mime type is valid' do
      let(:mime_type) { 'image/jpeg' }
      it 'should call remove_media!' do
        expect(edm_web_resource).to_not receive(:remove_media!)
        edm_web_resource.validate
      end
    end

    context 'when the mime type is invalid' do
      let(:mime_type) { 'video/x-ms-wmv' }
      it 'should call remove_media!' do
        expect(edm_web_resource).to receive(:remove_media!)
        edm_web_resource.validate
      end
    end

    context 'when the file was too large' do
      let(:mime_type) { 'image/jpeg' }
      let(:file) { double('fake_file', size: 52428801) }
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

  describe 'media' do
    let(:web_resource) { create(:edm_web_resource, media: image_file) }
    subject { web_resource.media }

    describe '#store_dir' do
      it 'is nil' do
        expect(subject.store_dir).to be_nil
      end
    end

    describe '#filename' do
      it 'is derived from UUID, with preferred extension' do
        expect(subject.filename).to eq(web_resource.uuid + '.jpeg')
      end
    end

    describe '#path' do
      it 'is just the filename' do
        expect(subject.path).to eq(subject.filename)
      end
    end
  end

  describe 'thumbnail generation after media edit' do
    context 'when the webresource is created' do
      context 'when it is an edm_isShownBy' do
        it 'is expected to queue a thumbnail job' do
          expect(ActiveJob::Base.queue_adapter).to receive(:enqueue).with(ThumbnailJob)
          described_class.create(media: image_file, edm_rights: create(:cc_license).id)
        end
      end
    end

    context 'when the web_resource already exists' do
      let(:web_resource) { create(:edm_web_resource, media: image_file) }

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
          web_resource.media = image_file
          expect(ActiveJob::Base.queue_adapter).to receive(:enqueue).with(ThumbnailJob)
          web_resource.save
        end
      end
    end
  end

  describe 'deletion' do
    let(:contribution) { create(:contribution, ore_aggregation: ore_aggregation) }
    let(:ore_aggregation) { create(:ore_aggregation, edm_isShownBy: web_resource) }
    let(:web_resource) { create(:edm_web_resource) }

    context 'when it belongs to a published contribution' do
      before do
        contribution.publish!
      end
      it 'should not allow deletion' do
        expect(web_resource.destroy).to eq(false)
      end
    end

    context 'when it belongs to a previously published contribution' do
      before do
        contribution.publish
        contribution.save
        contribution.unpublish
        contribution.save
      end
      it 'should not allow deletion' do
        expect(web_resource.destroy).to eq(false)
      end
    end

    context 'when it belonged to a previously published, but now deleted contribution' do
      before do
        contribution.publish
        contribution.save
        contribution.unpublish
        contribution.save
        contribution.wipe!
      end
      it 'should not allow deletion' do
        expect(web_resource.destroy).to eq(false)
      end
    end

    context 'when it belongs to a never published contribution' do
      before do
        contribution # call contribution to load instances
      end
      it 'should remove any versions' do
        expect(web_resource).to receive(:remove_versions)
        expect(web_resource.destroy).to eq(true)
      end
    end
  end
end
