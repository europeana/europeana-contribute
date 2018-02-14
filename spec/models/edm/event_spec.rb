# frozen_string_literal: true

require 'support/matchers/model_rejects_if_blank'

RSpec.describe EDM::Event do
  describe 'class' do

    subject { described_class }

    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(Mongoid::Uuid) }
    it { is_expected.to include(Blankness::Mongoid) }
    it { is_expected.to include(RDF::Graphable) }

    it { is_expected.to reject_if_blank(:edm_happenedAt) }
    it { is_expected.to reject_if_blank(:edm_occurredAt) }
  end

  describe '#name' do
    subject do
      build(:edm_event).tap do |event|
        event.skos_prefLabel = skos_prefLabel if candidates.include?(:skos_prefLabel)
        event.edm_happenedAt = edm_happenedAt if candidates.include?(:edm_happenedAt)
        event.edm_occurredAt = edm_occurredAt if candidates.include?(:edm_occurredAt)
      end
    end

    let(:candidates) { [] }
    let(:skos_prefLabel) { Forgery::LoremIpsum.words }
    let(:edm_happenedAt) do
      build(:edm_place).tap do |place|
        name = Forgery::Address.street_address
        allow(place).to receive(:name) { name }
      end
    end
    let(:edm_occurredAt) do
      build(:edm_time_span).tap do |time_span|
        name = Forgery::Date.date.to_s
        allow(time_span).to receive(:name) { name }
      end
    end

    context 'without skos_prefLabel, edm_happenedAt or edm_occurredAt' do
      it 'equals _id' do
        expect(subject.name).to eq(subject.id.to_s)
      end
    end

    context 'with only skos_prefLabel' do
      let(:candidates) { %i(skos_prefLabel) }
      it 'equals skos_prefLabel' do
        expect(subject.name).to eq(skos_prefLabel)
      end
    end

    context 'with only edm_happenedAt' do
      let(:candidates) { %i(edm_happenedAt) }
      it 'equals edm_happenedAt.name' do
        expect(subject.name).to eq(edm_happenedAt.name)
      end
    end

    context 'with only edm_occurredAt' do
      let(:candidates) { %i(edm_occurredAt) }
      it 'equals edm_occurredAt.name' do
        expect(subject.name).to eq(edm_occurredAt.name)
      end
    end

    context 'with skos_prefLabel and edm_happenedAt' do
      let(:candidates) { %i(skos_prefLabel edm_happenedAt) }
      it 'equals "skos_prefLabel, edm_happenedAt.name"' do
        expect(subject.name).to eq("#{skos_prefLabel}, #{edm_happenedAt.name}")
      end
    end

    context 'with skos_prefLabel and edm_occurredAt' do
      let(:candidates) { %i(skos_prefLabel edm_occurredAt) }
      it 'equals "skos_prefLabel, edm_occurredAt.name"' do
        expect(subject.name).to eq("#{skos_prefLabel}, #{edm_occurredAt.name}")
      end
    end

    context 'with edm_happenedAt and edm_occurredAt' do
      let(:candidates) { %i(edm_happenedAt edm_occurredAt) }
      it 'equals "edm_happenedAt.name, edm_occurredAt.name"' do
        expect(subject.name).to eq("#{edm_happenedAt.name}, #{edm_occurredAt.name}")
      end
    end

    context 'with skos_prefLabel, edm_happenedAt and edm_occurredAt' do
      let(:candidates) { %i(skos_prefLabel edm_happenedAt edm_occurredAt) }
      it 'equals "skos_prefLabel, edm_happenedAt.name, edm_occurredAt.name"' do
        expect(subject.name).to eq("#{skos_prefLabel}, #{edm_happenedAt.name}, #{edm_occurredAt.name}")
      end
    end
  end
end
