# frozen_string_literal: true

require 'support/shared_contexts/controllers/http_request_headers'
require 'support/shared_examples/controllers/http_response_content_types'
require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe StoriesController do
  describe 'GET index' do
    context 'when user is authorised' do
      let(:current_user) { create(:user, role: :events) }

      before do
        allow(subject).to receive(:current_user) { current_user }
      end

      it 'responds with status code 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'assigns stories to @stories' do
        current_user.events.push(create(:edm_event))
        3.times { create(:story, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, edm_wasPresentAt: current_user.events.first))) }
        get :index
        expect(assigns(:stories)).to be_a(Enumerable)
        expect(assigns(:stories).size).to eq(3)
        expect(assigns(:stories).all? { |story| story.is_a?(Story) }).to be true
      end

      it 'assigns events to @events' do
        5.times { current_user.events.push(create(:edm_event)) }
        get :index
        expect(assigns(:events)).to be_a(Enumerable)
        expect(assigns(:events).size).to eq(5)
        expect(assigns(:events).all? { |event| event.is_a?(EDM::Event) }).to be true
      end

      it 'renders HTML' do
        get :index
        expect(response.content_type).to eq('text/html')
      end
    end

    context 'when user is unauthorised' do
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
    let(:action) { proc { get :show, params: { uuid: uuid } } }

    context 'when CHO is not found' do
      let(:uuid) { SecureRandom.uuid }
      it_behaves_like 'HTTP 404 status'
    end

    context 'when CHO is found' do
      include_context 'HTTP Accept request header'

      let(:story) { create(:story, ore_aggregation: create(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho))) }
      let(:uuid) { story.ore_aggregation.edm_aggregatedCHO.uuid }

      context 'when requested format is JSON-LD' do
        let(:content_type) { 'application/ld+json' }
        it_behaves_like 'HTTP 200 status'
        it_behaves_like 'HTTP response content type'
      end

      context 'when requested format is N-Triples' do
        let(:content_type) { 'application/n-triples' }
        it_behaves_like 'HTTP 200 status'
        it_behaves_like 'HTTP response content type'
      end

      context 'when requested format is RDF/XML' do
        let(:content_type) { 'application/rdf+xml' }
        it_behaves_like 'HTTP 200 status'
        it_behaves_like 'HTTP response content type'
      end

      context 'when requested format is Turtle' do
        let(:content_type) { 'text/turtle' }
        it_behaves_like 'HTTP 200 status'
        it_behaves_like 'HTTP response content type'
      end

      context 'when requested format is unsupported' do
        let(:content_type) { 'application/pdf' }
        it_behaves_like 'HTTP 406 status'
      end
    end
  end
end
