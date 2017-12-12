# frozen_string_literal: true

RSpec.describe 'requests for /migration' do
  it 'redirects GET / to /migration' do
    get('/migration')
    expect(response).to render_template(:index)
  end

  it 'redirects GET / to /migration/new' do
    get('/migration/new')
    expect(response).to render_template(:new)
  end
end
