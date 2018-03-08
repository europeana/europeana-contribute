# frozen_string_literal: true

RSpec.describe InclusionOfEachElementValidator do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      def self.model_name
        ActiveModel::Name.new(self, nil, 'garment')
      end

      attr_accessor :sizes
      validates :sizes, inclusion_of_each_element: { in: %i(small medium large) }
    end
  end

  subject { model_class.new(sizes: sizes) }

  context 'when all values are included' do
    let(:sizes) { %i(small large) }
    it { is_expected.to be_valid }
  end

  context 'when any value is not included' do
    let(:sizes) { %i(tiny small medium large huge) }
    it { is_expected.not_to be_valid }
  end
end
