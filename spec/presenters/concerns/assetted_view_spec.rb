# frozen_string_literal: true

RSpec.shared_examples 'a toggled feature' do |js_var_name, env_var_name|
  subject { js_vars.detect { |js_var| js_var[:name] == js_var_name }[:value] }

  context 'when env var absent' do
    before { ENV.delete(env_var_name) }
    it { is_expected.to be false }
  end

  context 'when env var = "0"' do
    before { ENV[env_var_name] = '0' }
    it { is_expected.to be false }
  end

  context 'when env var = "false"' do
    before { ENV[env_var_name] = 'false' }
    it { is_expected.to be false }
  end

  context 'when env var = "1"' do
    before { ENV[env_var_name] = '1' }
    it { is_expected.to be true }
  end

  context 'when env var = "true"' do
    before { ENV[env_var_name] = 'true' }
    it { is_expected.to be true }
  end
end

RSpec.describe AssettedView do
  let(:presenter_class) do
    Class.new do
      include AssettedView
      def params; {}; end

      def asset_path(*_); end
    end
  end

  describe '#js_vars' do
    let(:js_vars) { presenter_class.new.js_vars }

    describe 'enableFormValidation' do
      it_behaves_like 'a toggled feature', 'enableFormValidation', 'ENABLE_JS_FORM_VALIDATION'
    end

    describe 'enableFormSave' do
      it_behaves_like 'a toggled feature', 'enableFormSave', 'ENABLE_JS_FORM_SAVE'
    end
  end
end
