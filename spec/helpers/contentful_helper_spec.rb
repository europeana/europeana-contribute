# frozen_string_literal: true

require 'support/shared_contexts/stubbed_requests/contentful'

RSpec.describe ContentfulHelper do
  include_context 'Contentful stubbed requests'

  describe '#contentful_client' do
    it 'should return a Contentful client' do
      client = helper.contentful_client
      expect(client.class).to eq(Contentful::Client)
      expect(client.configuration[:access_token]).to eq('dummy_token')
      expect(client.configuration[:api_url]).to eq('cdn.contentful.com')
    end
  end

  describe '#contentful_preview_client' do
    it 'should return a Contentful client, using preview settings' do
      preview_client = helper.contentful_preview_client
      expect(preview_client.class).to eq(Contentful::Client)
      expect(preview_client.configuration[:access_token]).to eq('dummy_preview_token')
      expect(preview_client.configuration[:api_url]).to eq('preview.contentful.com')
    end
  end
end
