# frozen_string_literal: true

RSpec.describe RecaptchaHelper do
  describe '#recaptcha_form_attributes' do
    before do
      allow(Recaptcha.configuration).to receive(:site_key) { 'TEST_KEY'}
    end
    context 'when NO user is signed in' do
      it 'should return the reCAPTCHA key' do
        expect(helper.recaptcha_form_attributes).to eq({'recaptcha-site-key': 'TEST_KEY'})
      end
    end

    context 'when the user is signed in' do
      before do
        user = create(:user)
        sign_in user
      end
      it 'should return nil' do
        expect(helper.recaptcha_form_attributes).to be_nil
      end
    end
  end
end
