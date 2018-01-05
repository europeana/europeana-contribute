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
      describe 'validity' do
        it 'should be valid' do
          expect(subject.valid?).to eq(true)
        end
      end
    end

    context 'when the file is of type audio' do
      let(:mime_type) { 'audio/mp3' }
      describe 'validity' do
        it 'should be valid' do
          expect(subject.valid?).to eq(true)
        end
      end
    end

    context 'when the file type is not supported' do
      let(:mime_type) { 'application/pdf' }
      describe 'validity' do
        it 'should NOT be valid' do
          expect(subject.valid?).to eq(false)
        end
      end
    end
  end
end
