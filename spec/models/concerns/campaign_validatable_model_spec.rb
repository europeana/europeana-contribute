# frozen_string_literal: true

RSpec.describe CampaignValidatableModel do
  before(:all) do
    module Campaigns
      module Test
        class ProviderValidator < ActiveModel::Validator
          def validate(record)
            record.errors.add(:base, 'invalid')
          end
        end
      end
    end
  end

  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include CampaignValidatableModel

      attr_accessor :edm_provider, :dc_title
    end
  end

  let(:edm_provider_without_validator_class) { 'Some Provider' }
  let(:edm_provider_with_validator_class) { 'Test Provider' }

  describe '#campaign_validator_class_name' do
    context 'with edm_provider' do
      subject { model_class.new(edm_provider: edm_provider_without_validator_class) }

      it 'constructs validator class name from edm_provider' do
        expect(subject.campaign_validator_class_name).to eq('Campaigns::Some::ProviderValidator')
      end
    end

    context 'without edm_provider' do
      subject { model_class.new.campaign_validator_class_name }

      it { is_expected.to be_nil }
    end
  end

  describe '#campaign_validator_class' do
    context 'with edm_provider' do
      context 'without validator class defined' do
        subject { model_class.new(edm_provider: edm_provider_without_validator_class).campaign_validator_class }

        it { is_expected.to be_nil }
      end

      context 'with validator class defined' do
        subject { model_class.new(edm_provider: edm_provider_with_validator_class) }

        it 'returns validator class derived from edm_provider' do
          expect(subject.campaign_validator_class).to eq(Campaigns::Test::ProviderValidator)
        end
      end
    end

    context 'without edm_provider' do
      subject { model_class.new.campaign_validator_class }

      it { is_expected.to be_nil }
    end
  end

  describe '#campaign_validator' do
    context 'with edm_provider' do
      context 'without validator class defined' do
        subject { model_class.new(edm_provider: edm_provider_without_validator_class) }

        it 'does not add any validations' do
          expect(subject).to be_valid
        end
      end

      context 'with validator class defined' do
        subject { model_class.new(edm_provider: edm_provider_with_validator_class) }

        it 'runs validations from validator class' do
          expect(subject).not_to be_valid
        end
      end
    end

    context 'without edm_provider' do
      subject { model_class.new }

      it 'does not add any validations' do
        expect(subject).to be_valid
      end
    end
  end
end
