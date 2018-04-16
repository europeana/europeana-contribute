# frozen_string_literal: true

require 'support/shared_examples/models/blankness_check'

RSpec.shared_examples 'a removable attribute' do
  context 'when blank' do
    subject { model_class.new("#{attr_name}": blank_value) }

    it 'is removed' do
      subject.save
      expect(subject.attributes).not_to have_key(attr_name)
    end
  end

  context 'when present' do
    subject { model_class.new("#{attr_name}": present_value) }

    it 'is preserved' do
      expect(subject.attributes).to have_key(attr_name)
      expect(subject.attributes[attr_name]).to eq(present_value)
      subject.save
      expect(subject.attributes).to have_key(attr_name)
      expect(subject.attributes[attr_name]).to eq(present_value)
    end
  end
end

RSpec.describe Blankness::Attributes do
  let(:model_class) do
    Class.new do
      extend ActiveModel::Callbacks

      define_model_callbacks :save

      include Blankness::Attributes

      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = attributes
      end

      def save
        run_callbacks :save
      end
    end
  end

  subject { model_class.new }

  it_behaves_like 'blankness check', :all_attributes_blank?

  describe '#blank_attribute_value?' do
    subject { model_class.new.blank_attribute_value?(attr_value) }

    ['', nil, [], ['', nil, {}], {}, { a: '', b: nil, c: [] }].each do |blank|
      context "when value is #{blank.inspect}" do
        let(:attr_value) { blank }
        it { is_expected.to be true }
      end
    end

    ['a', 0, ['a'], ['a', nil, {}], { a: 'a' }, { a: 'a', b: nil, c: [] }].each do |present|
      context "when value is #{present.inspect}" do
        let(:attr_value) { present }
        it { is_expected.to be false }
      end
    end
  end

  describe '#reject_blank_values!' do
    context 'when value is a Hash' do
      it 'removes blank values' do
        instance = model_class.new(dc_title: { en: '', fr: 'Paris' })
        instance.save
        expect(instance.attributes[:dc_title]).to have_key(:fr)
        expect(instance.attributes[:dc_title]).not_to have_key(:en)
      end
    end

    context 'when value is an Array' do
      it 'removes blank values' do
        instance = model_class.new(dc_title: ['', 'title'])
        instance.save
        expect(instance.attributes[:dc_title]).to include('title')
        expect(instance.attributes[:dc_title]).not_to include('')
      end
    end
  end

  describe '#reject_blank_attributes!' do
    it 'is called by save callback' do
      expect(subject).to receive(:reject_blank_attributes!)
      subject.save
    end

    describe 'attributes' do
      let(:attr_name) { :dc_title }

      context 'when value is a Hash' do
        let(:blank_value) { { en: '', fr: '' } }
        let(:present_value) { { en: '', fr: 'Paris' } }
        it_behaves_like 'a removable attribute'
      end

      context 'when value is an Array' do
        let(:blank_value) { [nil, {}] }
        let(:present_value) { ['Title', '', 'Alternative'] }
        it_behaves_like 'a removable attribute'
      end

      context 'when value is a String' do
        let(:blank_value) { '' }
        let(:present_value) { 'Title' }
        it_behaves_like 'a removable attribute'
      end
    end
  end
end
