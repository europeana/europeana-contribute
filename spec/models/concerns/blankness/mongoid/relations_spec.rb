# frozen_string_literal: true

require 'support/shared_examples/models/blankness_check'

RSpec.shared_examples 'a removable relation' do
  context 'when blank' do
    subject { model_class.new("#{attr_name}": blank_value) }
    it 'is removed' do
      expect(subject.send(attr_name)).to eq(blank_value)
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

RSpec.describe Blankness::Mongoid::Relations do
  before(:all) do
    module Dummy
      class Base
        include Mongoid::Document
        include Blankness::Mongoid::Relations

        checks_blankness_with :blank_attributes?

        def blank_attributes?
          dc_title.blank?
        end

        def save
          run_callbacks :save
        end
      end

      class Relation < Base
        field :dc_title
        belongs_to :belongs_to_has_one_relation, class_name: 'Dummy::Primary', inverse_of: :has_one_relation
        belongs_to :belongs_to_has_many_relation, class_name: 'Dummy::Primary', inverse_of: :has_many_relation
        has_one :has_one_relation, class_name: 'Dummy::Primary', inverse_of: :belongs_to_relation
        has_and_belongs_to_many :has_and_belongs_to_many_relation, class_name: 'Dummy::Primary', inverse_of: :has_and_belongs_to_many_relation
      end

      class Embed < Base
        field :dc_title
        embedded_in :one_embedded_in_relation, class_name: 'Dummy::Primary', inverse_of: :embeds_one_relation
        embedded_in :many_embedded_in_relation, class_name: 'Dummy::Primary', inverse_of: :embeds_many_relation
      end

      class Primary < Base
        field :dc_title
        embeds_one :embeds_one_relation, class_name: 'Dummy::Embed', inverse_of: :one_embedded_in_relation, cascade_callbacks: true
        embeds_many :embeds_many_relation, class_name: 'Dummy::Embed', inverse_of: :many_embedded_in_relation, cascade_callbacks: true
        belongs_to :belongs_to_relation, class_name: 'Dummy::Relation', inverse_of: :has_one_relation
        has_one :has_one_relation, class_name: 'Dummy::Relation', inverse_of: :belongs_to_has_one_relation
        has_many :has_many_relation, class_name: 'Dummy::Relation', inverse_of: :belongs_to_has_many_relation
        has_and_belongs_to_many :has_and_belongs_to_many_relation, class_name: 'Dummy::Relation', inverse_of: :has_and_belongs_to_many_relation
        rejects_blank :embeds_one_relation, :embeds_many_relation, :belongs_to_relation,
                      :has_one_relation, :has_many_relation, :has_and_belongs_to_many_relation
        is_present_unless_blank :embeds_one_relation, :embeds_many_relation, :belongs_to_relation,
                                :has_one_relation, :has_many_relation, :has_and_belongs_to_many_relation
      end
    end
  end

  let(:model_class) { Dummy::Primary }
  let(:relation_class) { Dummy::Relation }
  let(:embed_class) { Dummy::Embed }

  let(:blank_relation) { proc { relation_class.new(dc_title: '') } }
  let(:present_relation) { proc { relation_class.new(dc_title: 'Title') } }

  let(:blank_embed) { proc { embed_class.new(dc_title: '') } }
  let(:present_embed) { proc { embed_class.new(dc_title: 'Title') } }

  subject { model_class.new }

  it_behaves_like 'blankness check', :all_relations_blank?

  describe '#blank?' do
    subject { model_instance.blank? }

    context 'when relations are all blank' do
      let(:model_instance) do
        model_class.new.tap do |instance|
          instance.embeds_many_relation = [blank_embed.call, blank_embed.call]
          instance.belongs_to_relation = blank_relation.call
        end
      end

      it { is_expected.to be true }
    end

    context 'when relations are not all blank' do
      let(:model_instance) do
        model_class.new.tap do |instance|
          instance.embeds_many_relation = [present_embed.call, blank_embed.call]
          instance.belongs_to_relation = blank_relation.call
        end
      end

      it { is_expected.to be false }
    end
  end

  describe '#blank_relation_value?' do
    subject { model_class.new.blank_relation_value?(relation_value) }

    context 'when relation is blank' do
      context 'single object' do
        let(:relation_value) { blank_relation.call }

        it { is_expected.to be true }
      end

      context 'multiple objects' do
        let(:relation_value) { [blank_relation.call, blank_relation.call] }

        it { is_expected.to be true }
      end
    end

    context 'when relation has non-blank attrs' do
      let(:relation_value) { present_relation.call }
      it { is_expected.to be false }
    end
  end

  describe '#reject_blank_relations!' do
    it 'is called by save callback' do
      expect(subject).to receive(:reject_blank_relations!)
      subject.save
    end

    describe 'relations' do
      context 'when embeds_one' do
        let(:attr_name) { :embeds_one_relation }
        let(:blank_value) { blank_embed.call }
        let(:present_value) { present_embed.call }
        it_behaves_like 'a removable relation'
      end

      context 'when belongs_to' do
        let(:attr_name) { :belongs_to_relation }
        let(:blank_value) { blank_relation.call }
        let(:present_value) { present_relation.call }
        it_behaves_like 'a removable relation'
      end

      context 'when has_one' do
        let(:attr_name) { :has_one_relation }
        let(:blank_value) { blank_relation.call }
        let(:present_value) { present_relation.call }
        it_behaves_like 'a removable relation'
      end

      context 'when embeds_many' do
        let(:attr_name) { :embeds_many_relation }
        let(:blank_value) { [blank_embed.call, blank_embed.call] }
        let(:present_value) { [present_embed.call] }

        it_behaves_like 'a removable relation'

        context 'when some are blank, others present' do
          let(:mixed_value) { [blank_embed.call, present_embed.call] }
          subject { model_class.new("#{attr_name}": mixed_value) }

          it 'removes the blank ones' do
            subject.save
            expect(subject.send(attr_name)).not_to include(mixed_value.first)
          end

          it 'preseves the present ones' do
            subject.save
            expect(subject.send(attr_name)).to include(mixed_value.last)
          end
        end
      end

      context 'when has_many' do
        let(:attr_name) { :has_many_relation }
        let(:blank_value) { [blank_relation.call, blank_relation.call] }
        let(:present_value) { [present_relation.call] }

        it_behaves_like 'a removable relation'

        context 'when some are blank, others present' do
          let(:mixed_value) { [blank_relation.call, present_relation.call] }
          subject { model_class.new("#{attr_name}": mixed_value) }

          it 'removes the blank ones' do
            subject.save
            expect(subject.send(attr_name)).not_to include(mixed_value.first)
          end

          it 'preseves the present ones' do
            subject.save
            expect(subject.send(attr_name)).to include(mixed_value.last)
          end
        end
      end

      context 'when has_and_belongs_to_many' do
        let(:attr_name) { :has_and_belongs_to_many_relation }
        let(:blank_value) { [blank_relation.call, blank_relation.call] }
        let(:present_value) { [present_relation.call] }

        it_behaves_like 'a removable relation'

        context 'when some are blank, others present' do
          let(:mixed_value) { [blank_relation.call, present_relation.call] }
          subject { model_class.new("#{attr_name}": mixed_value) }

          it 'removes the blank ones' do
            subject.save
            expect(subject.send(attr_name)).not_to include(mixed_value.first)
          end

          it 'preseves the present ones' do
            subject.save
            expect(subject.send(attr_name)).to include(mixed_value.last)
          end
        end
      end
    end
  end
end
