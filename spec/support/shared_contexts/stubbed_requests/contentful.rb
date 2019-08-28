# frozen_string_literal: true

RSpec.shared_context 'Contentful stubbed requests' do
  before do
    Rails.application.config.x.contentful = OpenStruct.new(
      access_token: 'dummy_token',
      preview_access_token: 'dummy_preview_token',
      space: 'dummy_space'
    ).freeze

    stub_request(:get, 'https://cdn.contentful.com/spaces/dummy_space/environments/master/content_types?limit=1000').
      to_return(status: 200, body: File.read(File.expand_path('../responses/contentful/content_types.json', __dir__)))

    static_pages = [[:home, :root], :not_found, :about]
    static_pages.each do |page|
      identifier = page.is_a?(Array) ? page.first : page
      basename = page.is_a?(Array) ? page.last : page

      stub_request(:get, "https://cdn.contentful.com/spaces/dummy_space/environments/master/entries?content_type=staticPage&fields.identifier=#{identifier}&include=2").
        to_return(status: 200, body: File.read(File.expand_path("../responses/contentful/static_pages/#{basename}.json", __dir__)))
    end
  end
end
