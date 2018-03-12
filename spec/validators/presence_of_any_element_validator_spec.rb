# frozen_string_literal: true

RSpec.describe PresenceOfAnyElementValidator do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      def self.model_name
        ActiveModel::Name.new(self, nil, 'book')
      end

      attr_accessor :authors
      validates :authors, presence_of_any_element: true
    end
  end

  subject { model_class.new(authors: authors) }

  context 'when any value is non-blank' do
    let(:authors) { ['Anna Bell', ''] }
    it { is_expected.to be_valid }
  end

  context 'when all values are blank' do
    let(:authors) { ['', ''] }
    it { is_expected.not_to be_valid }
  end
end
