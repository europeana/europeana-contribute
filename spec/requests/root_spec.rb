# frozen_string_literal: true

require 'support/shared_contexts/stubbed_requests/contentful'

RSpec.describe 'requests for /' do
  include_context 'Contentful stubbed requests'

  it 'renders /pages/show' do
    get('/')
    expect(response).to render_template('pages/show')
  end
end
