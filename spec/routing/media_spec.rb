# frozen_string_literal: true

RSpec.describe 'routes for /media' do
  let(:uuid) { SecureRandom.uuid }
  it 'routes GET /media/:uuid to MediaController#show' do
    expect(get("/media/#{uuid}")).to route_to('media#show', uuid: uuid)
  end

  it 'routes GET /media/:uuid/w200 to MediaController#show' do
    expect(get("/media/#{uuid}/w200")).to route_to('media#show', uuid: uuid, size: 'w200')
  end

  it 'routes GET /media/:uuid/w400 to MediaController#show' do
    expect(get("/media/#{uuid}/w400")).to route_to('media#show', uuid: uuid, size: 'w400')
  end

  it 'does not route GET /media/:uuid/w100 to MediaController#show' do
    expect(get("/media/#{uuid}/w100")).not_to route_to('media#show', uuid: uuid, size: 'w100')
  end
end
