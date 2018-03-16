# frozen_string_literal: true

RSpec.describe Serialisation do
  subject { create(:serialisation) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:contribution).of_type(Contribution).
        as_inverse_of(:serialisations).with_dependent(nil)
    }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(contribution_id: 1) }
    it { is_expected.to have_index_for(format: 1) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:format) }
    it { is_expected.to validate_inclusion_of(:format).to_allow(%w(rdfxml)) }
    it { is_expected.to validate_uniqueness_of(:format).scoped_to(:contribution_id) }
    it { is_expected.to validate_presence_of(:contribution) }
  end
end
