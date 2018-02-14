# frozen_string_literal: true

RSpec.shared_examples 'HTTP response content type' do
  before { action.call }
  subject { response.content_type }
  it { is_expected.to eq(content_type) }
end
