# frozen_string_literal: true

RSpec.describe Environment do
  describe '#variables' do
    subject { described_class.variables }

    it 'equals ENV' do
      expect(subject).to eq(ENV)
    end
  end

  describe '#feature_toggled?' do
    let(:env_var_name) { 'ENABLE_NEW_FEATURE' }

    before do
      ENV[env_var_name] = env_var_value
    end

    subject { described_class.feature_toggled?(env_var_name) }

    %w(1 on true yes).each do |toggle_on|
      context %(when value is "#{toggle_on}") do
        let(:env_var_value) { toggle_on }
        it { is_expected.to be true }
      end
    end

    ['0', 'off', 'false', 'no', '/dev/null', nil].each do |toggle_off|
      context %(when value is "#{toggle_off}") do
        let(:env_var_value) { toggle_off }
        it { is_expected.to be false }
      end
    end
  end
end
