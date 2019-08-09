# frozen_string_literal: true

require 'support/shared_contexts/stubbed_requests/contentful'

RSpec.describe ContentfulHelper do
  include_context 'Contentful stubbed requests'

  describe '#contentful' do
    it 'should return a Contentful client' do
      expect(helper.contentful.class).to eq(Contentful::Client)
    end
  end
end
