# frozen_string_literal: true

require 'support/shared_examples/controllers/http_response_statuses'

RSpec.shared_examples 'Forbidden for guest user' do
  let(:current_user) { nil }
  before { action.call }
  subject { response }
  it_behaves_like 'HTTP 403 status'
end

RSpec.shared_examples 'Forbidden for events user' do
  let(:current_user) { create(:user, role: :events) }
  before { action.call }
  subject { response }
  it_behaves_like 'HTTP 403 status'
end
