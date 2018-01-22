# frozen_string_literal: true

RSpec.describe AutocompletableModel do
  let(:model_class) do
    Class.new do
      include AutocompletableModel

      def self.attribute_names
        ['name', 'title']
      end
    end
  end

  subject { model_class.new }

  describe '#[attribute]_autocomplete' do
    context 'with known attribute' do
      let(:attribute_name) { model_class.attribute_names.first }

      it 'does not raise exception' do
        expect { subject.send(:"#{attribute_name}_autocomplete").not_to raise_exception }
      end

      it 'delegates to #autocomplete' do
        expect(subject).to receive(:autocomplete).with(attribute_name)
        subject.send(:"#{attribute_name}_autocomplete")
      end
    end

    context 'with unknown attribute' do
      let(:attribute_name) { 'unknown' }

      it 'raises exception' do
        expect { subject.send(:"#{attribute_name}_autocomplete").to raise_exception }
      end
    end
  end

  describe '#[attribute]_autocomplete=' do
    context 'with known attribute' do
      let(:attribute_name) { model_class.attribute_names.first }

      it 'does not raise exception' do
        expect { subject.send(:"#{attribute_name}_autocomplete=", 'value').not_to raise_exception }
      end

      it 'delegates to #autocomplete' do
        expect(subject).to receive(:autocomplete=).with(attribute_name, 'value')
        subject.send(:"#{attribute_name}_autocomplete=", 'value')
      end
    end

    context 'with unknown attribute' do
      let(:attribute_name) { 'unknown' }

      it 'raises exception' do
        expect { subject.send(:"#{attribute_name}_autocomplete=", 'value').to raise_exception }
      end
    end
  end

  describe '#autocomplete' do
    context 'with known attribute' do
      let(:attribute_name) { model_class.attribute_names.first }

      context 'without autocomplete value stored' do
        it 'returns nil' do
          expect(subject.autocomplete(attribute_name)).to be_nil
        end
      end

      context 'with autocomplete value stored' do
        before do
          subject.instance_variable_set(:@autocomplete, HashWithIndifferentAccess.new("#{attribute_name}": 'value'))
        end

        it 'is returned' do
          expect(subject.autocomplete(attribute_name)).to eq('value')
        end
      end
    end

    context 'with unknown attribute' do
      let(:attribute_name) { 'unknown' }

      it 'raises ArgumentError' do
        expect { subject.autocomplete(attribute_name) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#autocomplete=' do
    context 'with known attribute' do
      let(:attribute_name) { model_class.attribute_names.first }

      it 'stores value' do
        subject.send(:autocomplete=, attribute_name, 'value')
        expect(subject.instance_variable_get(:@autocomplete)[attribute_name]).to eq('value')
      end
    end

    context 'with unknown attribute' do
      let(:attribute_name) { 'unknown' }

      it 'raises ArgumentError' do
        expect { subject.send(:autocomplete=, attribute_name, 'value') }.to raise_exception(ArgumentError)
      end
    end
  end
end
