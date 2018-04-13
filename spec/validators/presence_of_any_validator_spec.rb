# frozen_string_literal: true

RSpec.describe PresenceOfAnyValidator do
  subject { record_class.new(attributes) }

  context 'with two attributes' do
    before do
      module Dummy
        class PresenceOfAnyValidator
          include ActiveModel::Model
          include ActiveModel::Validations
          attr_accessor :name, :title
          def attributes
            { name: name, title: title }
          end
          validates_with ::PresenceOfAnyValidator, of: %i(name title)
        end
      end
    end
    let(:record_class) { Dummy::PresenceOfAnyValidator }

    context 'when only first is present' do
      let(:attributes) { { name: 'Name' } }
      it { is_expected.to be_valid }
    end

    context 'when only second is present' do
      let(:attributes) { { title: 'Title' } }
      it { is_expected.to be_valid }
    end

    context 'when both are present' do
      let(:attributes) { { name: 'Name', title: 'Title' } }
      it { is_expected.to be_valid }
    end

    context 'when neither is present' do
      let(:attributes) { {} }
      it { is_expected.not_to be_valid }

      it 'flags error on both attributes' do
        subject.validate
        expect(subject.errors[:name]).not_to be_blank
        expect(subject.errors[:title]).not_to be_blank
      end
    end
  end

  context 'when class is a Mongoid::Document with blankness concern' do
    context 'with one validated attribute a relation' do
      before do
        module Dummy
          class PresenceOfAnyInMongoidDocumentParent
            include Mongoid::Document
            include Blankness::Mongoid::Attributes
            include Blankness::Mongoid::Relations
            field :name
            has_many :children, class_name: 'Dummy::PresenceOfAnyInMongoidDocumentChild', inverse_of: :parent
            validates_with ::PresenceOfAnyValidator, of: %i(name children)
          end
          class PresenceOfAnyInMongoidDocumentChild
            include Mongoid::Document
            include Blankness::Mongoid::Attributes
            include Blankness::Mongoid::Relations
            field :number
            belongs_to :parent, class_name: 'Dummy::PresenceOfAnyInMongoidDocumentParent', inverse_of: :children, optional: true
          end
        end
      end

      context 'with just relation set' do
        subject { Dummy::PresenceOfAnyInMongoidDocumentParent.new(children: children) }

        context 'when relation members are not blank' do
          let(:children) { [Dummy::PresenceOfAnyInMongoidDocumentChild.new(number: 1), Dummy::PresenceOfAnyInMongoidDocumentChild.new(number: 2)] }
          it { is_expected.to be_valid }

          context 'when saved' do
            subject { Dummy::PresenceOfAnyInMongoidDocumentParent.create(children: children) }
            it 'is still valid when reloaded' do
              subject.reload
              expect(subject).to be_valid
            end
          end
        end

        context 'when relation members are blank' do
          let(:children) { [Dummy::PresenceOfAnyInMongoidDocumentChild.new, Dummy::PresenceOfAnyInMongoidDocumentChild.new] }
          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
