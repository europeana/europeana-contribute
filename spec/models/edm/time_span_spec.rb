# frozen_string_literal: true

RSpec.describe EDM::TimeSpan do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Model) }
  end

  describe '#name' do
    subject { described_class.new(edm_begin: edm_begin, edm_end: edm_end, skos_prefLabel: skos_prefLabel) }

    let(:edm_begin) { nil }
    let(:edm_end) { nil }
    let(:skos_prefLabel) { nil }

    context 'without skos_prefLabel, edm_begin or edm_end' do
      it 'equals _id' do
        expect(subject.name).to eq(subject.id.to_s)
      end
    end

    context 'with only skos_prefLabel' do
      let(:skos_prefLabel) { 'May Day' }
      it 'equals skos_prefLabel' do
        expect(subject.name).to eq(skos_prefLabel)
      end
    end

    context 'with only edm_begin' do
      let(:edm_begin) { '2010-09-22' }
      it 'equals edm_begin' do
        expect(subject.name).to eq(edm_begin)
      end
    end

    context 'with only edm_end' do
      let(:edm_end) { '2010-09-26' }
      it 'equals edm_end' do
        expect(subject.name).to eq(edm_end)
      end
    end

    context 'with edm_begin and edm_end' do
      let(:edm_begin) { '2010-09-22' }
      let(:edm_end) { '2010-09-26' }
      it 'equals edm_begin–edm_end' do
        expect(subject.name).to eq("#{edm_begin}–#{edm_end}")
      end
    end

    context 'with skos_prefLabel, edm_begin and edm_end' do
      let(:skos_prefLabel) { 'May Day' }
      let(:edm_begin) { '2010-09-22' }
      let(:edm_end) { '2010-09-26' }
      it 'equals skos_prefLabel (edm_begin–edm_end)' do
        expect(subject.name).to eq("#{skos_prefLabel} (#{edm_begin}–#{edm_end})")
      end
    end
  end
end
