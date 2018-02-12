# frozen_string_literal: true

RSpec.describe CC::License do
  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.not_to include(Mongoid::Uuid) }
  end
end
