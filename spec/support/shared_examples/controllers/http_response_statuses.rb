# frozen_string_literal: true

RSpec.shared_examples 'HTTP response status' do |code|
  before { action.call }
  subject { response }

  it { is_expected.to have_http_status(code) }

  if [302, 303].include?(code)
    it { is_expected.to redirect_to(redirect_location) }
  end
end
