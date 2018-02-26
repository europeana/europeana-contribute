# frozen_string_literal: true

RSpec.describe 'routes for /contributions' do
  it 'routes GET /contributions to StoriesController#index' do
    expect(get('/contributions')).to route_to('contributions#index')
  end
end
