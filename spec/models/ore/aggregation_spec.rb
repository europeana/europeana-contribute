# frozen_string_literal: true

RSpec.describe ORE::Aggregation do
  subject { create(:ore_aggregation) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(RDFModel) }
    it { is_expected.to include(RemoveBlankAttributes) }
  end

  it 'should autobuild edm_aggregatedCHO' do
    expect(subject.edm_aggregatedCHO).not_to be_nil
  end
end
