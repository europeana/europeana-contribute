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
end
