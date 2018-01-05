# frozen_string_literal: true

RSpec.describe AutocompletableModel do
  let(:model_class) do
    Class.new do
      attr_writer :attributes

      def attributes
        @attributes ||= {}
      end
    end
  end

  subject do
    model_class.new.tap do |instance|
      instance.extend(AutocompletableModel)
    end
  end

  describe '#autocompletes' do
    it 'defines singleton _value accessors' do
      expect(subject).not_to respond_to(:title_value)
      expect(subject).not_to respond_to(:title_value=)
      subject.autocompletes(:title)
      expect(subject).to respond_to(:title_value)
      expect(subject).to respond_to(:title_value=)
    end

    it 'defines singleton _text accessors' do
      expect(subject).not_to respond_to(:title_text)
      expect(subject).not_to respond_to(:title_text=)
      subject.autocompletes(:title)
      expect(subject).to respond_to(:title_text)
      expect(subject).to respond_to(:title_text=)
    end

    it 'defines #autocomplete_attributes' do
      expect(subject).not_to respond_to(:autocomplete_attributes)
      subject.autocompletes(:description)
      expect(subject).to respond_to(:autocomplete_attributes)
      expect(subject.autocomplete_attributes).to be_a(Hash)
      expect(subject.autocomplete_attributes[:description]).to be_a(Hash)
    end

    describe '#autocomplete_attributes' do
      let(:attribute_name) { :description }
      let(:options) { { this: :that, something: :else } }

      it 'stores arbitrary supplied options' do
        subject.autocompletes(attribute_name, options)
        expect(subject.autocomplete_attributes[attribute_name][:options]).to eq(options)
      end

      it 'stores text/value field names' do
        subject.autocompletes(attribute_name, options)
        expect(subject.autocomplete_attributes[attribute_name][:names][:text]).to eq(:"#{attribute_name}_text")
        expect(subject.autocomplete_attributes[attribute_name][:names][:value]).to eq(:"#{attribute_name}_value")
      end
    end

    context 'when attribute is :title' do
      let(:attribute_name) { :title }

      describe '#title_text' do
        it 'returns title text from autocomplete_attributes' do
          subject.autocompletes(attribute_name)
          subject.autocomplete_attributes[attribute_name][:value] = 'text'
          expect(subject.title_text).to eq('text')
        end
      end

      describe '#title_text=' do
        it 'stores title text in autocomplete_attributes' do
          subject.autocompletes(attribute_name)
          subject.title_text = 'text'
          expect(subject.autocomplete_attributes[attribute_name][:value]).to eq('text')
        end
      end

      describe '#title_value' do
        it 'returns title value from attributes' do
          subject.autocompletes(attribute_name)
          subject.attributes[attribute_name] = 'value'
          expect(subject.title_value).to eq('value')
        end
      end

      describe '#title_value=' do
        it 'stores title value in attributes' do
          subject.autocompletes(attribute_name)
          subject.title_value = 'value'
          expect(subject.attributes[attribute_name]).to eq('value')
        end
      end
    end
  end
end
