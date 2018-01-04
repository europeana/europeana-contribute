# frozen_string_literal: true

RSpec.describe CampaignValidator do
  let(:validator_class) do
    Class.new(CampaignValidator) do
      def validate_edm_agent(_record); end
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
end
