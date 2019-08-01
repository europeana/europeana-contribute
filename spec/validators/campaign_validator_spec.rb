# frozen_string_literal: true

RSpec.describe CampaignValidator do
  before(:each) do
    create(:cc_license, rdf_about: 'http://creativecommons.org/publicdomain/mark/1.0/')
    create(:cc_license, rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/')
    create(:cc_license, rdf_about: 'http://rightsstatements.org/vocab/CNE/1.0/')
  end

  let(:validator_class) do
    Class.new(CampaignValidator) do
      def validate_edm_agent(_record); end
    end
  end
  let(:aggregation) do
    build(:ore_aggregation).tap do |aggregation|
      aggregation.edm_aggregatedCHO = build(:edm_provided_cho, dc_title: nil, dc_description: nil)
      aggregation.edm_aggregatedCHO.dc_contributor_agent = build(:edm_agent)
      aggregation.edm_aggregatedCHO.dc_subject_agents << build(:edm_agent)
      aggregation.edm_isShownBy = build(:edm_web_resource, :image_media)
      aggregation.edm_hasViews << build(:edm_web_resource, :audio_media)
    end
  end
  let(:contribution) do
    build(:contribution).tap do |con|
      con.campaign = create(:campaign)
      con.ore_aggregation = aggregation
    end
  end

  subject { validator_class.new }

  describe '#validate' do
    context 'with validation method for record class' do
      let(:record_class) { EDM::Agent }
      let(:validation_method) { 'validate_edm_agent' }

      it 'calls validation method' do
        expect(subject).to receive(:validate_edm_agent)
        subject.validate(record_class.new)
      end
    end

    context 'without validation method for record class' do
      let(:record_class) { EDM::Place }
      let(:validation_method) { 'validate_edm_place' }

      it 'does not raise exception' do
        expect { subject.validate(record_class.new) }.not_to raise_exception
      end
    end
  end

  context 'when record is EDM::ProvidedCHO' do
    subject { contribution.ore_aggregation.edm_aggregatedCHO }

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
      subject { contribution.ore_aggregation.edm_aggregatedCHO.dc_contributor_agent }

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
      subject { contribution.ore_aggregation.edm_aggregatedCHO.dc_subject_agents.first }

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

  context 'when record is a EDM::WebResource' do
    let(:error_message) { I18n.t('contribute.campaigns.generic.form.validation.web-resource-license') }

    context 'edm_isShownBy' do
      subject { contribution.ore_aggregation.edm_isShownBy }
      context 'when edm_rights is present' do
        it 'validates presence of edm_rights' do
          subject.validate
          expect(subject.errors[:edm_rights]).not_to include(error_message)
        end
      end

      context 'when edm_rights is NOT present' do
        it 'validates presence of edm_rights' do
          subject.edm_rights = nil
          subject.validate
          expect(subject.errors[:edm_rights_id]).to include(error_message)
        end
      end
    end

    context 'edm_hasViews' do
      subject { contribution.ore_aggregation.edm_hasViews.first }
      context 'when edm_rights is present' do
        it 'validates presence of edm_rights' do
          subject.validate
          expect(subject.errors[:edm_rights]).not_to include(error_message)
        end
      end

      context 'when edm_rights is NOT present' do
        it 'validates presence of edm_rights' do
          subject.edm_rights = nil
          subject.validate
          expect(subject.errors[:edm_rights_id]).to include(error_message)
        end
      end
    end
  end
end
