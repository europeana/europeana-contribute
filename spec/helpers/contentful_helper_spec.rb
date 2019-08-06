# frozen_string_literal: true

RSpec.describe ContentfulHelper do
  describe '#contentful' do
    before do
      Rails.application.config.x.contentful = OpenStruct.new(
        access_token: 'dummy_token',
        space: 'dummy_space'
      ).freeze

      stub_request(:get, "https://cdn.contentful.com/spaces/dummy_space/environments/master/content_types?limit=1000").
        with(  headers: {
          'Accept-Encoding'=>'gzip',
          'Authorization'=>'Bearer dummy_token',
          'Connection'=>'close',
          'Content-Type'=>'application/vnd.contentful.delivery.v1+json',
          'Host'=>'cdn.contentful.com'
        }).
        to_return(status: 200, body: %{
                                        {
                                          "sys": {
                                            "type": "Array"
                                          },
                                          "total": 1,
                                          "skip": 0,
                                          "limit": 1000,
                                          "items": []
                                        }
}, headers: {})
    end

    it 'should return a contentful client' do
      expect(helper.contentful.class).to eq(Contentful::Client)
    end
  end
end
