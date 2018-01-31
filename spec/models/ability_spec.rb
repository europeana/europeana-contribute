# frozen_string_literal: true

require 'cancan/matchers'

RSpec.describe Ability do
  subject { described_class.new(user) }

  context 'when user has role :admin' do
    let(:user) { build(:user, role: :admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'when user has role :events' do
    let(:user) { build(:user, role: :events) }

    it { is_expected.not_to be_able_to(:manage, :all) }
  end

  context 'when user has no role' do
    let(:user) { build(:user, role: nil) }

    it { is_expected.not_to be_able_to(:manage, :all) }
  end
end
