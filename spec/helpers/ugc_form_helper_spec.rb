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

  describe '#t' do
    subject { helper.t('key', options) }
    after(:each) { I18n.backend.reload! }

    context 'without campaign option' do
      let(:options) { {} }
      it 'uses standard scope' do
        I18n.backend.store_translations(:en, key: 'non-campaign')
        expect(subject).to eq('non-campaign')
      end
    end

    context 'with campaign option' do
      let(:options) { { campaign: 'testing' } }
      context 'and campaign-specific key exists' do
        it 'returns campaign-specific value' do
          I18n.backend.store_translations(:en, contribute: { campaigns: { testing: { form: { key: 'specific' } } } })
          expect(subject).to eq('specific')
        end
      end

      context 'but no campaign-specific key exists' do
        context 'but generic key exists' do
          it 'returns generic value' do
            I18n.backend.store_translations(:en, contribute: { campaigns: { generic: { form: { key: 'generic' } } } })
            expect(subject).to eq('generic')
          end
        end

        context 'and no generic key either' do
          it 'returns notice' do
            expect(subject).to start_with('translation missing')
          end
        end
      end
    end
  end
end
