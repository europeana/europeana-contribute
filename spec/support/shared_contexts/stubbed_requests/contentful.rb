# frozen_string_literal: true

RSpec.shared_context 'Contentful stubbed requests' do
  before do
    Rails.application.config.x.contentful = OpenStruct.new(
      access_token: 'dummy_token',
      space: 'dummy_space'
    ).freeze

    stub_request(:get, 'https://cdn.contentful.com/spaces/dummy_space/environments/master/content_types?limit=1000').
      to_return(status: 200, body: File.read(File.expand_path('../responses/contentful/content_types.json', __dir__)))

    stub_request(:get, 'https://cdn.contentful.com/spaces/dummy_space/environments/master/entries?content_type=staticPage&fields.identifier=/&include=2').
      to_return(status: 200, body: File.read(File.expand_path('../responses/contentful/static_pages/root.json', __dir__)))
  end
end
