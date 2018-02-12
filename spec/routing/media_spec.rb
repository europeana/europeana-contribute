# frozen_string_literal: true

RSpec.describe 'routes for /media' do
  it 'routes GET /media/:uuid to MediaController#show' do
    uuid = SecureRandom.uuid
    expect(get("/media/#{uuid}")).to route_to('media#show', uuid: uuid)
  end
end
