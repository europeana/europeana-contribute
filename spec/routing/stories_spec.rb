# frozen_string_literal: true

RSpec.describe 'routes for /oai' do
  it 'routes GET /stories to StoriesController#index' do
    expect(get('/stories')).to route_to('stories#index')
  end
end
