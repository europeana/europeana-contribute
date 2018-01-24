# frozen_string_literal: true

RSpec.shared_examples 'a removable attribute' do
  context 'when blank' do
    subject { model_class.new("#{attr_name}": blank_value) }
    it 'is removed' do
      subject.save
      expect(subject.attributes).not_to have_key(attr_name.to_s)
    end
  end

  context 'when present' do
    subject { model_class.new("#{attr_name}": present_value) }
    it 'is preserved' do
      expect(subject.attributes).to have_key(attr_name.to_s)
      expect(subject.attributes[attr_name.to_s]).to eq(present_value)
      subject.save
      expect(subject.attributes).to have_key(attr_name.to_s)
      expect(subject.attributes[attr_name.to_s]).to eq(present_value)
    end
  end
end

RSpec.shared_examples 'a removable relation' do
  context 'when blank' do
    subject { model_class.new("#{attr_name}": blank_value) }
    it 'is removed' do
      subject.save
      expect(subject.send(attr_name)).to be_blank
    end
  end

  context 'when present' do
    subject { model_class.new("#{attr_name}": present_value) }
    it 'is preserved' do
      expect(subject.send(attr_name)).to eq(present_value)
      subject.save
      expect(subject.send(attr_name)).to eq(present_value)
    end
  end
end

RSpec.describe RemoveBlankAttributes do
  before(:all) do
    module RemoveBlankAttributes
      module Dummy
        class Base
          include Mongoid::Document
          include RemoveBlankAttributes

          def save
            run_callbacks :save
          end
        end

        class Model < Base
          field :dc_title
          embeds_one :dc_type, class_name: 'RemoveBlankAttributes::Dummy::Relation'
          embeds_many :dc_subject, class_name: 'RemoveBlankAttributes::Dummy::Relation'
        end

        class Relation < Base
          field :dc_description
        end
      end
    end
  end

  let(:model_class) { RemoveBlankAttributes::Dummy::Model }
  let(:relation_class) { RemoveBlankAttributes::Dummy::Relation }

  subject { model_class.new }

  describe '#remove_blank_attributes!' do
    it 'is called by save callback' do
      expect(subject).to receive(:remove_blank_attributes!)
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

  describe '#remove_blank_embeds!' do
    subject { model_class.new }

    it 'is called by save callback' do
      expect(subject).to receive(:remove_blank_embeds!)
      subject.save
    end

    describe 'relations' do
      context 'when value is a single Mongoid:Document' do
        let(:attr_name) { :dc_type }
        let(:blank_value) { relation_class.new(dc_description: '') }
        let(:present_value) { relation_class.new(dc_description: 'Description') }
        it_behaves_like 'a removable relation'
      end

      context 'when value is multiple Mongoid:Documents' do
        let(:attr_name) { :dc_subject }
        let(:blank_value) { [relation_class.new(dc_description: ''), relation_class.new(dc_description: '')] }
        let(:present_value) { [relation_class.new(dc_description: 'Description')] }

        it_behaves_like 'a removable relation'

        context 'when some are blank, others present' do
          let(:blank_relation) { relation_class.new(dc_description: '') }
          let(:present_relation) { relation_class.new(dc_description: 'Description') }
          subject { model_class.new("#{attr_name}": [blank_relation, present_relation]) }

          it 'removes the blank ones' do
            subject.save
            expect(subject.send(attr_name)).not_to include(blank_relation)
          end

          it 'preseves the present ones' do
            subject.save
            expect(subject.send(attr_name)).to include(present_relation)
          end
        end
      end
    end
  end
end
