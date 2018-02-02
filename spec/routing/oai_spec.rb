# frozen_string_literal: true

RSpec.describe 'routes for /oai' do
  it 'routes GET /oai to OAIController#index' do
    expect(get('/oai')).to route_to('oai#index')
  end
end
