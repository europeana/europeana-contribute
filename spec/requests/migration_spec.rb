# frozen_string_literal: true

require 'support/shared_contexts/campaigns/migration'

RSpec.describe 'requests for /migration' do
  include_context 'migration campaign'

  it 'renders template for /migration/new' do
    get('/migration/new')
    expect(response).to render_template(:new)
  end
end
