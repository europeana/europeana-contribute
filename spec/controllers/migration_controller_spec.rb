# frozen_string_literal: true

require 'support/shared_contexts/campaigns/migration'

RSpec.describe MigrationController do
  include_context 'migration campaign'

  let(:valid_contribution_params) {
    {
      contribution: {
        age_confirm: true,
        content_policy_accept: true,
        display_and_takedown_accept: true,
        ore_aggregation_attributes: {
          edm_aggregatedCHO_attributes: {
            dc_title: 'title',
            dc_description: 'description',
            dc_contributor_agent_attributes: {
              foaf_name: 'name',
              foaf_mbox: 'me@example.org',
              skos_prefLabel: 'me'
            },
            dc_subject: 'Subject'
          },
          edm_isShownBy_attributes: {
            media: fixture_file_upload(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg')
          }
        }
      }
    }
  }

  describe 'GET index' do
    it 'renders the index HTML template' do
      get :index
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:index)
    end
  end

  describe 'GET new' do
    it 'assigns @contribution with built associations' do
      get :new
      expect(assigns(:contribution)).to be_a(Contribution)
      expect(assigns(:contribution)).to be_new_record
      expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO).not_to be_nil
      expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO.dc_contributor_agent).not_to be_nil
      expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO.dc_subject_agents).not_to be_nil
      expect(assigns(:contribution).ore_aggregation.edm_isShownBy).not_to be_nil
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
      let(:params) { valid_contribution_params }

      it 'saves the contribution' do
        expect { post :create, params: params }.not_to raise_exception
        expect(assigns(:contribution).errors.full_messages).to be_blank
        expect(assigns(:contribution)).to be_persisted
      end

      it 'saves ore_aggregation' do
        post :create, params: params
        expect(assigns(:contribution).ore_aggregation.errors.full_messages).to be_blank
        expect(assigns(:contribution).ore_aggregation).to be_persisted
      end

      it 'saves ore_aggregation.edm_aggregatedCHO' do
        post :create, params: params
        expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO.errors.full_messages).to be_blank
        expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO).to be_persisted
      end

      it 'save edm_isShownBy' do
        post :create, params: params
        expect(assigns(:contribution).ore_aggregation.edm_isShownBy.errors.full_messages).to be_blank
        expect(assigns(:contribution).ore_aggregation.edm_isShownBy).to be_persisted
      end

      it 'redirects to index' do
        post :create, params: params
        expect(response).to redirect_to(action: :index, c: 'eu-migration')
      end

      it 'saves defaults' do
        post :create, params: params
        expect(assigns(:contribution).ore_aggregation.edm_dataProvider).to eq(Rails.configuration.x.edm.data_provider)
        expect(assigns(:contribution).ore_aggregation.edm_provider).to eq(Rails.configuration.x.edm.provider)
      end

      it 'flashes a notification' do
        post :create, params: params
        expect(flash[:notice]).to eq(I18n.t('contribute.campaigns.migration.pages.create.flash.success'))
      end

      describe 'publication status' do
        context 'when user may save drafts' do
          let(:user) { build(:user, role: :events) }
          before do
            allow(user).to receive(:active?) { true }
            allow(controller).to receive(:current_user) { user }
          end

          it 'is draft' do
            post :create, params: params
            expect(assigns(:contribution)).to be_draft
          end
        end

        context 'when user may not save drafts' do
          before do
            allow(controller).to receive(:current_user) { build(:user, role: nil) }
          end

          it 'is published' do
            post :create, params: params
            expect(assigns(:contribution)).to be_published
          end
        end
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          contribution: {
            ore_aggregation_attributes: {
              edm_aggregatedCHO_attributes: {
                dc_contributor_agent_attributes: {
                  foaf_name: 'name',
                  foaf_mbox: 'me@example.org',
                  skos_prefLabel: 'me'
                }
              }
            }
          }
        }
      }

      it 'does not save the contribution' do
        post :create, params: params
        expect(assigns(:contribution)).not_to be_valid
        expect(assigns(:contribution)).not_to be_persisted
      end

      it 'does not save valid associations' do
        post :create, params: params
        expect(assigns(:contribution).ore_aggregation.edm_aggregatedCHO.dc_contributor_agent).not_to be_persisted
      end

      # it 'does not save invalid associations' do
      #   post :create, params: params
      #   expect(assigns(:contribution).edm_isShownBy).not_to be_valid
      #   expect(assigns(:contribution).edm_isShownBy).not_to be_persisted
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

  describe 'GET edit' do
    let(:contribution) { create(:contribution) }
    let(:params) { { id: contribution.id } }

    before do
      allow(controller).to receive(:current_user) { create(:user, role: :admin) }
    end

    it 'assigns AASM variables' do
      get :edit, params: params
      expect(contribution).to be_draft
      expect(assigns(:permitted_aasm_events).map(&:name)).to eq(%i(publish))
    end
  end

  describe 'PUT update' do
    let(:contribution) { create(:contribution) }
    let(:params) { { id: contribution.id } }

    before do
      allow(controller).to receive(:current_user) { create(:user, role: :admin) }
    end

    context 'when AASM event changed' do
      let(:params) {
        {
          id: contribution.id,
          contribution: {
            aasm_state: 'publish',
            ore_aggregation_attributes: {
              edm_aggregatedCHO_attributes: {
                dc_subject: 'statefulness'
              }
            }
          }
        }
      }

      it 'fires AASM event' do
        expect(contribution).to be_draft
        expect(contribution).to be_valid

        put :update, params: params

        expect(assigns[:contribution].errors).to be_blank
        expect(response.status).to eq(302)
        expect(response).to redirect_to(controller: :contributions, action: :index, c: 'eu-migration')
        expect(contribution.reload).to be_published
      end
    end
  end
end
