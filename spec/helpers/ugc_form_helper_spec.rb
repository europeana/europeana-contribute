# frozen_string_literal: true

RSpec.describe UGCFormHelper do
  describe '#aasm_events_for_select' do
    let(:contribution) { Contribution.new }
    let(:events) { contribution.aasm.events(permitted: true) }
    subject { helper.aasm_events_for_select(events) }

    it 'has event name(s) as values' do
      expect(subject.first.last).to eq(:publish)
    end

    it 'translates event name(s) as text' do
      expect(subject.first.first).to eq('Publish')
    end
  end
end
