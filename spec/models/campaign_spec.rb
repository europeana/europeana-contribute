# frozen_string_literal: true

RSpec.describe Campaign do
  subject { create(:campaign) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
  end

  describe 'relations' do
    it {
      is_expected.to have_many(:contributions).of_type(Contribution).
        as_inverse_of(:campaign).with_dependent(:restrict)
    }
  end

  it { should validate_presence_of(:dc_identifier) }
  it { should validate_uniqueness_of(:dc_identifier) }
end
