# frozen_string_literal: true

require 'support/matchers/controllers/negotiate_content_type'
require 'support/shared_contexts/controllers/http_request_headers'
require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe ContributionsController do
  let(:admin_user) { create(:user, role: :admin) }
  let(:events_user) { create(:user, role: :events) }

  describe 'GET index' do
    before do
      allow(subject).to receive(:current_user) { current_user }
    end

    context 'when user is authorised' do
      let(:current_user) { admin_user }

      it 'responds with status code 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'assigns contributions to @contributions' do
        current_user.events.push(create(:edm_event))
        create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho)))
        3.times { create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, edm_wasPresentAt: current_user.events.first))) }
        get :index
        expect(assigns(:contributions)).to be_a(Enumerable)
        expect(assigns(:contributions).size).to eq(4)
        expect(assigns(:contributions).all? { |contribution| contribution.is_a?(Hash) }).to be true
        Contribution.all.each do |contribution|
          assigned_contribution = assigns(:contributions).detect { |c| c[:uuid] == contribution.ore_aggregation.edm_aggregatedCHO.uuid }
          expect(assigned_contribution[:status]).to eq(contribution.aasm_state)
          expect(assigned_contribution[:date]).to eq(contribution.created_at)
          expect(assigned_contribution[:media]).to eq(contribution.has_media?)
        end
      end

      it 'assigns events to @events' do
        5.times { current_user.events.push(create(:edm_event)) }
        get :index
        expect(assigns(:events)).to be_a(Enumerable)
        expect(assigns(:events).size).to eq(5)
        expect(assigns(:events).all? { |event| event.is_a?(EDM::Event) }).to be true
      end

      it 'enables deletion' do
        get :index
        expect(assigns(:deletion_enabled)).to eq(true)
      end

      it 'renders HTML' do
        get :index
        expect(response.content_type).to eq('text/html')
      end
    end

    context 'when the user has limited authorization' do
      let(:current_user) { events_user }

      before do
        current_user.events.push(create(:edm_event))
      end

      it 'responds with status code 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'assigns contributions to @contributions' do
        create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho)))
        3.times { create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, edm_wasPresentAt: current_user.events.first))) }
        get :index
        expect(assigns(:contributions)).to be_a(Enumerable)
        expect(assigns(:contributions).size).to eq(3)
        expect(assigns(:contributions).all? { |contribution| contribution.is_a?(Hash) }).to be true
        Contribution.all.each do |contribution|
          next if contribution.ore_aggregation.edm_aggregatedCHO.edm_wasPresentAt != current_user.events.first
          assigned_contribution = assigns(:contributions).detect { |c| c[:uuid] == contribution.ore_aggregation.edm_aggregatedCHO.uuid }
          expect(assigned_contribution[:status]).to eq(contribution.aasm_state)
          expect(assigned_contribution[:date]).to eq(contribution.created_at)
          expect(assigned_contribution[:media]).to eq(contribution.has_media?)
        end
      end

      it 'assigns events to @events' do
        5.times { current_user.events.push(create(:edm_event)) }
        get :index
        expect(assigns(:events)).to be_a(Enumerable)
        expect(assigns(:events).size).to eq(6) # 5 events created in this example + 1 created for the context
        expect(assigns(:events).all? { |event| event.is_a?(EDM::Event) }).to be true
      end

      it 'does NOT enable deletion' do
        get :index
        expect(assigns(:deletion_enabled)).to be_nil
      end

      it 'renders HTML' do
        get :index
        expect(response.content_type).to eq('text/html')
      end
    end

    context 'when user is unauthorised' do
      let(:current_user) { nil }

      it 'responds with status code 403' do
        get :index
        expect(response.status).to eq(403)
      end

      it 'renders plain text' do
        get :index
        expect(response.content_type).to eq('text/plain')
      end
    end
  end

  describe 'GET show' do
    include_context 'HTTP Accept request header'
    let(:action) { proc { get :show, params: { uuid: uuid } } }
    let(:content_type) { 'application/ld+json' }
    before { action.call }
    subject { response }

    context 'when CHO is not found' do
      context 'when there is no related deleted contribution' do
        let(:uuid) { SecureRandom.uuid }
        it_behaves_like 'HTTP 404 status'
      end

      context 'when there is a related deleted contribution' do
        let(:contribution) { create(:contribution, :deleted) }
        let(:uuid) { contribution.oai_pmh_record_id }
        it_behaves_like 'HTTP 410 status'
      end
    end

    context 'when CHO is found' do
      let(:uuid) { contribution.ore_aggregation.edm_aggregatedCHO.uuid }

      context 'when user is unauthorised' do
        let(:contribution) { create(:contribution) }
        it_behaves_like 'HTTP 403 status'
      end

      context 'when user is authorised' do
        let(:contribution) { create(:contribution, :published) }

        context 'when requested format is JSON-LD' do
          let(:content_type) { 'application/ld+json' }
          it { is_expected.to negotiate_content_type('application/ld+json') }
          it_behaves_like 'HTTP 200 status'
        end

        context 'when requested format is N-Triples' do
          let(:content_type) { 'application/n-triples' }
          it { is_expected.to negotiate_content_type('application/n-triples') }
          it_behaves_like 'HTTP 200 status'
        end

        context 'when requested format is RDF/XML' do
          let(:content_type) { 'application/rdf+xml' }
          it { is_expected.to negotiate_content_type('application/rdf+xml') }
          it_behaves_like 'HTTP 200 status'
        end

        context 'when requested format is Turtle' do
          let(:content_type) { 'text/turtle' }
          it { is_expected.to negotiate_content_type('text/turtle') }
          it_behaves_like 'HTTP 200 status'
        end

        context 'when requested format is unsupported' do
          let(:content_type) { 'application/pdf' }
          it_behaves_like 'HTTP 406 status'
        end
      end
    end
  end

  describe 'GET edit' do
    let(:action) { proc { get :edit, params: { uuid: uuid } } }

    context 'when CHO is not found' do
      let(:uuid) { SecureRandom.uuid }
      it_behaves_like 'HTTP 404 status'
    end

    context 'when CHO is found' do
      let(:uuid) { contribution.ore_aggregation.edm_aggregatedCHO.uuid }
      let(:contribution) { create(:contribution, campaign: create(:campaign, :migration)) }

      context 'when user is unauthorised' do
        it_behaves_like 'HTTP 403 status'
      end

      context 'when user is authorised' do
        let(:current_user) { admin_user }

        before do
          allow(controller).to receive(:current_user) { current_user }
        end

        it 'redirects to campaign controller edit action' do
          action.call
          expect(response).to redirect_to(controller: :migration, action: :edit, uuid: uuid)
        end
      end
    end
  end

  describe 'GET delete' do
    let(:contribution) { create(:contribution) }
    let(:params) { { uuid: uuid } }
    let(:uuid) { contribution.ore_aggregation.edm_aggregatedCHO.uuid }

    before do
      allow(controller).to receive(:current_user) { admin_user }
    end

    it 'renders the delete HTML template' do
      get :delete, params: params
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:delete)
    end
  end

  describe 'DELETE destroy' do
    let(:contribution) { create(:contribution) }
    let(:params) { { uuid: contribution.ore_aggregation.edm_aggregatedCHO.uuid } }

    context 'when the user is authorized' do
      before do
        allow(controller).to receive(:current_user) { admin_user }
        contribution # call contribution to ensure it is persisted
      end

      context 'when the contribution was NEVER published' do
        it 'destroys the contribution' do
          expect { delete :destroy, params: params }.to change { Contribution.count }.by(-1)
          expect(flash[:notice]).to include('Deleted:')
          expect(response.status).to eq(302)
          expect(response).to redirect_to(contributions_path)
        end
      end

      context 'when the contribution was published' do
        before do
          contribution.publish
          contribution.save
          contribution.unpublish
          contribution.save
        end

        it 'wipes the contribution' do
          expect { delete :destroy, params: params }.to_not change { Contribution.count }
          expect(flash[:notice]).to include('Deleted:')
          expect(response.status).to eq(302)
          expect(response).to redirect_to(contributions_path)
        end
      end
    end

    context 'when the user is NOT authorized' do
      before do
        allow(controller).to receive(:current_user) { events_user }
        contribution # call contribution to ensure it is persisted
      end

      it 'results in a unauthorized error' do
        expect { delete :destroy, params: params }.to_not change { Contribution.count }
        expect(response.status).to eq(403)
      end
    end
  end
end
