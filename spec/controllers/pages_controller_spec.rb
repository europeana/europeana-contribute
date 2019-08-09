# frozen_string_literal: true

require 'support/shared_contexts/stubbed_requests/contentful'
require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe PagesController do
  include_context 'Contentful stubbed requests'

  describe 'GET show' do
    let(:action) { proc { get :show, params: params } }

    context 'when page is found on Contentful' do
      let(:params) { { identifier: 'about' } }

      it 'made a request to Contentful API' do
        url = 'https://cdn.contentful.com/spaces/dummy_space/environments/master/entries?content_type=staticPage&fields.identifier=about&include=2'

        action.call
        expect(a_request(:get, url)).to have_been_made
      end

      it_behaves_like 'HTTP response status', 200

      it 'assigns @page' do
        action.call
        expect(assigns[:page]).not_to be_nil
      end
    end

    context 'when page is not found on Contentful' do
      let(:params) { { identifier: 'not_found' } }

      it 'made a request to Contentful API' do
        url = 'https://cdn.contentful.com/spaces/dummy_space/environments/master/entries?content_type=staticPage&fields.identifier=not_found&include=2'

        action.call
        expect(a_request(:get, url)).to have_been_made
      end

      it_behaves_like 'HTTP response status', 404
    end
  end
end
