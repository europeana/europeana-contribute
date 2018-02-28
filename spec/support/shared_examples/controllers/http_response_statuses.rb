# frozen_string_literal: true

# TODO: DRY this up

RSpec.shared_examples 'HTTP 200 status' do
  before { action.call }
  subject { response }
  it { is_expected.to have_http_status(200) }
end

RSpec.shared_examples 'HTTP 303 status' do
  before { action.call }
  subject { response }
  it { is_expected.to have_http_status(303) }
  it { is_expected.to redirect_to(location) }
end

RSpec.shared_examples 'HTTP 403 status' do
  before { action.call }
  subject { response }
  it { is_expected.to have_http_status(403) }
end

RSpec.shared_examples 'HTTP 404 status' do
  before { action.call }
  subject { response }
  it { is_expected.to have_http_status(404) }
end

RSpec.shared_examples 'HTTP 406 status' do
  before { action.call }
  subject { response }
  it { is_expected.to have_http_status(406) }
end
