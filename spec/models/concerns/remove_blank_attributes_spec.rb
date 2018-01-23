# frozen_string_literal: true

RSpec.describe RemoveBlankAttributes do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      extend ActiveModel::Callbacks
      define_model_callbacks :save
      include RemoveBlankAttributes

      attr_accessor :dc_title, :dc_subject

      def dc_title=(value)
        @dc_title = attributes[:dc_title] = value
      end

      def dc_subject=(value)
        @dc_subject = attributes[:dc_subject] = value
      end

      def attributes
        @attributes ||= {}
      end

      def save
        run_callbacks :save
      end
    end
  end

  describe 'blank association omission' do
    let(:attributes) { %i(dc_title dc_subject) }

    describe '.omit_blank_association' do
      it 'stores the attribute(s) name' do
        model_class.omit_blank_association(*attributes)
        expect(model_class.instance_variable_get(:@omitted_blank_associations)).to eq(attributes)
      end
    end

    describe '.omitted_blank_associations' do
      it 'defaults to empty array' do
        expect(model_class.omitted_blank_associations).to eq([])
      end

      it 'returns stored attribute(s) name' do
        model_class.instance_variable_set(:@omitted_blank_associations, attributes)
        expect(model_class.omitted_blank_associations).to eq(attributes)
      end
    end

    describe '#clear_omitted_blank_associations' do
      before do
        model_class.omit_blank_association(*attributes)
      end

      subject { model_class.new }

      it 'is called by save callback' do
        expect(subject).to receive(:clear_omitted_blank_associations)
        subject.save
      end

      describe 'attribute clearing' do
        subject { model_class.new("#{attr_name}": attr_value) }
        let(:attr_name) { :dc_title }

        context 'when attribute value is hash' do
          context 'with only blank values' do
            let(:attr_value) { { en: '', fr: '' } }

            it 'is deleted' do
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).not_to have_key(attr_name)
            end
          end

          context 'with any present values' do
            let(:attr_value) { { en: '', fr: 'Paris' } }

            it 'is not deleted' do
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
            end
          end
        end

        context 'when attribute value is blank array' do
          context 'with only blank values' do
            let(:attr_value) { [nil, {}] }

            it 'is deleted' do
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).not_to have_key(attr_name)
            end
          end

          context 'with any present values' do
            let(:attr_value) { ['Title', '', 'Alternative'] }

            it 'is not deleted' do
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
            end
          end
        end

        context 'when attribute value is blank scalar' do
          context 'when blank' do
            let(:attr_value) { '' }

            it 'is deleted' do
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).not_to have_key(attr_name)
            end
          end

          context 'when present' do
            let(:attr_value) { 'Title' }

            it 'is not deleted' do
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
              subject.send(:clear_omitted_blank_associations)
              expect(subject.attributes).to have_key(attr_name)
              expect(subject.attributes[attr_name]).to eq(attr_value)
            end
          end
        end
      end
    end
  end
end
