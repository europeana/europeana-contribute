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

    describe 'stories' do
      let(:story) { build(:ore_aggregation) }
      let(:event) { build(:edm_event) }

      it { is_expected.not_to be_able_to(:manage, ORE::Aggregation) }
      it { is_expected.to be_able_to(:index, ORE::Aggregation) }

      context 'when user is associated with event' do
        before { user.events.push(event) }

        context 'and story is too' do
          before { story.edm_aggregatedCHO.edm_wasPresentAt = event }
          it { is_expected.to be_able_to(:edit, story) }
        end

        context 'but story is not' do
          it { is_expected.not_to be_able_to(:edit, story) }
        end
      end

      context 'when user is not associated with event' do
        context 'and neither is story' do
          it { is_expected.not_to be_able_to(:edit, story) }
        end

        context 'but story is' do
          before { story.edm_aggregatedCHO.edm_wasPresentAt = event }
          it { is_expected.not_to be_able_to(:edit, story) }
        end
      end
    end

    describe 'events' do
      let(:event) { build(:edm_event) }

      it { is_expected.not_to be_able_to(:manage, EDM::Event) }

      context 'when user is associated with event' do
        before { user.events.push(event) }
        it { is_expected.to be_able_to(:read, event) }
      end

      context 'when user is not associated with event' do
        it { is_expected.not_to be_able_to(:read, event) }
      end
    end
  end

  context 'when user has no role' do
    let(:user) { build(:user, role: nil) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.not_to be_able_to(:manage, ORE::Aggregation) }
    it { is_expected.not_to be_able_to(:index, ORE::Aggregation) }
    it { is_expected.not_to be_able_to(:manage, EDM::Event) }
  end
end
