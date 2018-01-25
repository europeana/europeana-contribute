# frozen_string_literal: true

RSpec.describe MigrationController do
  describe 'GET index' do
    it 'renders the index HTML template' do
      get :index
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:index)
    end
  end

  describe 'GET new' do
    it 'assigns @aggregation with built associations' do
      get :new
      expect(assigns(:aggregation)).to be_a(ORE::Aggregation)
      expect(assigns(:aggregation)).to be_new_record
      expect(assigns(:aggregation).edm_aggregatedCHO).not_to be_nil
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_contributor).not_to be_nil
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_subject_agents).not_to be_nil
      expect(assigns(:aggregation).edm_isShownBy).not_to be_nil
    end

    it 'renders the new HTML template' do
      get :new
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:params) {
        {
          ore_aggregation: {
            edm_aggregatedCHO_attributes: {
              dc_title: 'title',
              dc_description: 'description',
              dc_contributor_attributes: {
                foaf_name: 'name',
                foaf_mbox: 'me@example.org',
                skos_prefLabel: 'me'
              }
            },
            edm_isShownBy_attributes: {
              media: fixture_file_upload(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg')
            }
          }
        }
      }

      it 'saves the aggregation' do
        expect { post :create, params: params }.not_to raise_exception
        expect(assigns(:aggregation)).to be_valid
        expect(assigns(:aggregation)).to be_persisted
      end

      it 'saves associations' do
        post :create, params: params
        expect(assigns(:aggregation).edm_isShownBy).to be_valid
        expect(assigns(:aggregation).edm_isShownBy).to be_persisted
      end

      it 'redirects to index' do
        post :create, params: params
        expect(response).to redirect_to(action: :index, c: 'eu-migration')
      end

      it 'save defaults' do
        post :create, params: params
        expect(assigns(:aggregation).edm_provider).to eq('Europeana Migration')
      end

      it 'flashes a notification'
    end

    context 'with invalid params' do
      let(:params) {
        {
          ore_aggregation: {
            edm_aggregatedCHO_attributes: {
              dc_contributor_attributes: {
                foaf_name: 'name',
                foaf_mbox: 'me@example.org',
                skos_prefLabel: 'me'
              }
            }
          }
        }
      }

      it 'does not save the aggregation' do
        post :create, params: params
        expect(assigns(:aggregation)).not_to be_valid
        expect(assigns(:aggregation)).not_to be_persisted
      end

      it 'does not save valid associations' do
        post :create, params: params
        expect(assigns(:aggregation).edm_aggregatedCHO.dc_contributor).to be_valid
        expect(assigns(:aggregation).edm_aggregatedCHO.dc_contributor).not_to be_persisted
      end

      # it 'does not save invalid associations' do
      #   post :create, params: params
      #   expect(assigns(:aggregation).edm_isShownBy).not_to be_valid
      #   expect(assigns(:aggregation).edm_isShownBy).not_to be_persisted
      # end

      it 'renders the new HTML template' do
        post :create, params: params
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('text/html')
        expect(response).to render_template(:new)
      end

      it 'shows error messages'
    end
  end
end
