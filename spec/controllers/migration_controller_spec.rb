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
    it 'assigns @aggregation' do
      get :new
      expect(assigns(:aggregation)).to be_a(ORE::Aggregation)
      expect(assigns(:aggregation)).to be_new_record
      expect(assigns(:aggregation).edm_aggregatedCHO).not_to be_nil
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_contributor).not_to be_nil
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_creator).not_to be_nil
      expect(assigns(:aggregation).edm_isShownBy).not_to be_nil
    end

    it 'marks fields for autocompletion' do
      get :new
      expect(assigns(:aggregation).edm_aggregatedCHO).to be_a(AutocompletableModel)
      expect(assigns(:aggregation).edm_aggregatedCHO.autocomplete_attributes).to have_key(:dc_subject)
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_creator).to be_a(AutocompletableModel)
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_creator.autocomplete_attributes).to have_key(:rdaGr2_placeOfBirth)
      expect(assigns(:aggregation).edm_aggregatedCHO.dc_creator.autocomplete_attributes).to have_key(:rdaGr2_placeOfDeath)
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
      it 'saves the aggregation'
      it 'redirects to index'
      it 'flashes a notification'
    end

    context 'with invalid params' do
      it 'does not save the aggregation'
      it 'renders the new HTML template'
      it 'shows error messages'
    end
  end
end
