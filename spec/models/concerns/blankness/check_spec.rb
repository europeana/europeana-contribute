# frozen_string_literal: true

RSpec.describe Blankness::Check do
  let(:model_class) do
    Class.new do
      include Blankness::Check
      def check_true?
        return true
      end
      def check_false?
        return false
      end
    end
  end

  let(:model_instance) { model_class.new }

  describe '#blank?' do
    context 'with one checker' do
      before do
        model_class.checks_blankness_with :check_true?
      end

      it 'checks with the checker' do
        expect(model_instance).to receive(:check_true?)
        model_instance.blank?
      end
    end

    context 'with two checkers' do
      before do
        model_class.checks_blankness_with :check_false?, :check_true?
      end

      it 'checks with all checkers' do
        expect(model_instance).to receive(:check_true?)
        expect(model_instance).to receive(:check_false?)
        model_instance.blank?
      end
    end
  end
end
