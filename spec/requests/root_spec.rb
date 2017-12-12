# frozen_string_literal: true

RSpec.describe 'requests for /' do
  it 'redirects GET / to /migration' do
    get('/')
    expect(response).to redirect_to('/migration')
  end
end
