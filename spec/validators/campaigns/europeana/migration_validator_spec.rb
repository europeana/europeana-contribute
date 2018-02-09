# frozen_string_literal: true

RSpec.describe Campaigns::Europeana::MigrationValidator do
  let(:aggregation) do
    build(:ore_aggregation, edm_provider: 'Europeana Migration').tap do |aggregation|
      aggregation.edm_aggregatedCHO = build(:edm_provided_cho, dc_title: nil, dc_description: nil)
      aggregation.edm_aggregatedCHO.dc_contributor_agent = build(:edm_agent)
      aggregation.edm_aggregatedCHO.dc_subject_agents << build(:edm_agent)
    end
  end

  context 'when record is EDM::ProvidedCHO' do
    subject { aggregation.edm_aggregatedCHO }

    it 'validates presence of dc_title' do
      subject.validate
      expect(subject.errors[:dc_title]).to include(I18n.t('errors.messages.blank'))
    end

    it 'validates presence of dc_description' do
      subject.validate
      expect(subject.errors[:dc_description]).to include(I18n.t('errors.messages.blank'))
    end
  end

  context 'when record is EDM::Agent' do
    context 'when record is for dc_contributor_agent' do
      subject { aggregation.edm_aggregatedCHO.dc_contributor_agent }

      it 'validates presence of foaf_mbox' do
        subject.validate
        expect(subject.errors[:foaf_mbox]).to include(I18n.t('errors.messages.blank'))
      end

      it 'validates presence of foaf_name' do
        subject.validate
        expect(subject.errors[:foaf_name]).to include(I18n.t('errors.messages.blank'))
      end

      it 'validates presence of skos_prefLabel' do
        subject.validate
        expect(subject.errors[:skos_prefLabel]).to include(I18n.t('errors.messages.blank'))
      end
    end

    context 'when record is not for dc_contributor_agent' do
      subject { aggregation.edm_aggregatedCHO.dc_subject_agents.first }

      it 'does not validate presence of foaf_mbox' do
        subject.validate
        expect(subject.errors[:foaf_mbox]).not_to include(I18n.t('errors.messages.blank'))
      end

      it 'does not validate presence of foaf_name' do
        subject.validate
        expect(subject.errors[:foaf_name]).not_to include(I18n.t('errors.messages.blank'))
      end

      it 'does not validate presence of skos_prefLabel' do
        subject.validate
        expect(subject.errors[:skos_prefLabel]).not_to include(I18n.t('errors.messages.blank'))
      end
    end
  end
end
