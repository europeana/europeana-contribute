# frozen_string_literal: true

require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe MediaController do
  describe 'GET show' do
    let(:action) { proc { get :show, params: params } }
    let(:params) { { uuid: uuid } }
    let(:web_resource) do
      create(:edm_web_resource, :image_media).tap do |web_resource|
        web_resource.media.recreate_versions!(:w400, :w200)
      end
    end
    let(:deleted_web_resource) { create(:deleted_resource, :web_resource) }

    let(:uuid) { web_resource.uuid }

    context 'when the EDM::WebResouce was deleted' do
      let(:uuid) { deleted_web_resource.resource_identifier }
      it_behaves_like 'HTTP response status', 410
    end

    context 'when web resource with UUID does not exist' do
      let(:uuid) { SecureRandom.uuid }
      it_behaves_like 'HTTP response status', 404
    end

    context 'when unauthorised' do
      it_behaves_like 'HTTP response status', 403
    end

    context 'when authorised' do
      before do
        allow(controller).to receive(:current_user) { build(:user, role: :admin) }
      end

      context 'when web resource with UUID exists' do
        let(:redirect_location) { web_resource.media_url }
        it_behaves_like 'HTTP response status', 303

        context 'with size=w200' do
          let(:params) { { uuid: uuid, size: 'w200' } }
          let(:redirect_location) { web_resource.media.url(:w200) }
          it_behaves_like 'HTTP response status', 303
        end

        context 'with size=w400' do
          let(:params) { { uuid: uuid, size: 'w400' } }
          let(:redirect_location) { web_resource.media.url(:w400) }
          it_behaves_like 'HTTP response status', 303
        end
      end
    end
  end
end
