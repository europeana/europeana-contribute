# frozen_string_literal: true

RSpec.describe CampaignValidatableModel do
  before(:all) do
    module Campaigns
      class TestValidator < ActiveModel::Validator
        def validate(record)
          record.errors.add(:base, 'invalid')
        end
      end
    end
  end

  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include CampaignValidatableModel

      attr_accessor :campaign, :dc_title
    end
  end

  let(:campaign_without_validator_class) { build(:campaign, dc_identifier: 'something') }
  let(:campaign_with_validator_class) { build(:campaign, dc_identifier: 'test') }

  describe '#campaign_validator_class_name' do
    context 'with campaign' do
      subject { model_class.new(campaign: campaign_with_validator_class) }

      it 'constructs validator class name from campaign' do
        expect(subject.campaign_validator_class_name).to eq('Campaigns::TestValidator')
      end
    end

    context 'without campaign' do
      subject { model_class.new.campaign_validator_class_name }

      it { is_expected.to be_nil }
    end
  end

  describe '#campaign_validator_class' do
    context 'with campaign' do
      context 'without validator class defined' do
        subject { model_class.new(campaign: campaign_without_validator_class).campaign_validator_class }

        it { is_expected.to eq(CampaignValidator) }
      end

      context 'with validator class defined' do
        subject { model_class.new(campaign: campaign_with_validator_class) }

        it 'returns validator class derived from campaign' do
          expect(subject.campaign_validator_class).to eq(Campaigns::TestValidator)
        end
      end
    end

    context 'without campaign' do
      subject { model_class.new.campaign_validator_class }

      it { is_expected.to be_nil }
    end
  end

  describe '#campaign_validator' do
    context 'with campaign' do
      context 'without validator class defined' do
        subject { model_class.new(campaign: campaign_without_validator_class) }

        it 'does not add any validations' do
          expect(subject).to be_valid
        end
      end

      context 'with validator class defined' do
        subject { model_class.new(campaign: campaign_with_validator_class) }

        it 'runs validations from validator class' do
          expect(subject).not_to be_valid
        end
      end
    end

    context 'without campaign' do
      subject { model_class.new }

      it 'does not add any validations' do
        expect(subject).to be_valid
      end
    end
  end
end
