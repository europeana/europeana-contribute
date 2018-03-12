# frozen_string_literal: true

require 'cancan/matchers'

RSpec.shared_examples 'guest user' do
  it { is_expected.not_to be_able_to(:manage, :all) }
  it { is_expected.not_to be_able_to(:manage, Contribution) }
  it { is_expected.not_to be_able_to(:index, Contribution) }
  it { is_expected.not_to be_able_to(:save_draft, Contribution) }
  it { is_expected.not_to be_able_to(:manage, EDM::Event) }

  describe 'contributions' do
    context 'when contribution is published' do
      let(:contribution) { build(:contribution, :published) }
      it { is_expected.to be_able_to(:show, contribution) }
    end

    context 'when contribution is draft' do
      let(:contribution) { build(:contribution) }
      it { is_expected.not_to be_able_to(:show, contribution) }
    end
  end
end

RSpec.describe Ability do
  subject { described_class.new(user) }

  context 'when user has role :admin' do
    let(:user) { build(:user, role: :admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'when user has role :events' do
    let(:user) { build(:user, role: :events) }

    context 'but no events' do
      it_behaves_like 'guest user'
    end

    context 'and at least one event' do
      before { user.events.push(build(:edm_event)) }

      it { is_expected.not_to be_able_to(:manage, :all) }

      describe 'contributions' do
        let(:contribution) { build(:contribution) }
        let(:event) { build(:edm_event) }

        it { is_expected.not_to be_able_to(:manage, Contribution) }
        it { is_expected.to be_able_to(:index, Contribution) }
        it { is_expected.to be_able_to(:show, Contribution) }
        it { is_expected.to be_able_to(:save_draft, Contribution) }

        context 'when user is associated with event' do
          before { user.events.push(event) }

          context 'and contribution is too' do
            before { contribution.ore_aggregation.edm_aggregatedCHO.edm_wasPresentAt = event }
            it { is_expected.to be_able_to(:edit, contribution) }
          end

          context 'but contribution is not' do
            it { is_expected.not_to be_able_to(:edit, contribution) }
          end
        end

        context 'when user is not associated with event' do
          context 'and neither is contribution' do
            it { is_expected.not_to be_able_to(:edit, contribution) }
          end

          context 'but contribution is' do
            before { contribution.ore_aggregation.edm_aggregatedCHO.edm_wasPresentAt = event }
            it { is_expected.not_to be_able_to(:edit, contribution) }
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
  end

  context 'when user has no role' do
    let(:user) { build(:user, role: nil) }
    it_behaves_like 'guest user'
  end
end
