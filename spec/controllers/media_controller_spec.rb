# frozen_string_literal: true

require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe MediaController do
  describe 'GET show' do
    subject { proc { get :show, params: { uuid: uuid } } }

    context 'when web resource with UUID exists' do
      let(:web_resource) { create(:edm_web_resource) }
      let(:uuid) { web_resource.uuid }
      let(:location) { web_resource.media_url }

      it_behaves_like 'HTTP 303 status'
    end

    context 'when web resource with UUID does not exist' do
      let(:uuid) { SecureRandom.uuid }
      it_behaves_like 'HTTP 404 status'
    end
  end
end
