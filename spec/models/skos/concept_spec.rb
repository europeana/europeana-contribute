# frozen_string_literal: true

RSpec.describe SKOS::Concept do
  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
  end
end
