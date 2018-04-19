# frozen_string_literal: true

require 'support/shared_examples/controllers/authorisation'
require 'support/shared_examples/controllers/http_response_statuses'

RSpec.describe EventsController do
  describe 'GET index' do
    let(:action) { proc { get(:index) } }

    it_behaves_like 'Forbidden for guest user'
    it_behaves_like 'Forbidden for events user'

    context 'when user is an admin' do
      let(:current_user) { create(:user, role: :admin) }

      before do
        3.times { create(:edm_event) }
      end

      it 'assigns events to @events' do
        action.call
        expect(assigns(:events)).to eq(EDM::Event.all)
      end

      it_behaves_like 'HTTP response status', 200
    end
  end

  describe 'GET new' do
    let(:action) { proc { get(:new) } }

    it_behaves_like 'Forbidden for guest user'
    it_behaves_like 'Forbidden for events user'

    context 'when user is an admin' do
      let(:current_user) { create(:user, role: :admin) }

      it 'assigns new event to @event' do
        action.call
        expect(assigns(:event)).to be_an(EDM::Event)
        expect(assigns(:event)).not_to be_persisted
      end

      it_behaves_like 'HTTP response status', 200
    end
  end

  describe 'POST create' do
    let(:action) { proc { post(:create, params: params) } }

    context 'with valid params' do
      let(:params) do
        {
          edm_event: {
            skos_prefLabel: 'Event label'
          }
        }
      end

      it_behaves_like 'Forbidden for guest user'
      it_behaves_like 'Forbidden for events user'

      context 'when user is an admin' do
        let(:current_user) { create(:user, role: :admin) }
        let(:redirect_location) { controller.events_path }

        it 'persists event with params' do
          action.call
          expect(assigns(:event)).to be_an(EDM::Event)
          expect(assigns(:event)).to be_persisted
          expect(assigns(:event).skos_prefLabel).to eq(params[:edm_event][:skos_prefLabel])
        end

        it_behaves_like 'HTTP response status', 302
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          edm_event: {
            skos_prefLabel: ''
          }
        }
      end

      it_behaves_like 'Forbidden for guest user'
      it_behaves_like 'Forbidden for events user'

      context 'when user is an admin' do
        let(:current_user) { create(:user, role: :admin) }

        it 'does not persist event' do
          action.call
          expect(assigns(:event)).to be_an(EDM::Event)
          expect(assigns(:event)).not_to be_persisted
        end

        it_behaves_like 'HTTP response status', 400

        it 'renders new' do
          action.call
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET edit' do
    let(:action) { proc { get(:edit, params: { uuid: event.uuid }) } }
    let(:event) { create(:edm_event) }

    it_behaves_like 'Forbidden for guest user'
    it_behaves_like 'Forbidden for events user'

    context 'when user is an admin' do
      let(:current_user) { create(:user, role: :admin) }

      it 'assigns requested event to @event' do
        action.call
        expect(assigns(:event)).to eq(event)
      end

      it_behaves_like 'HTTP response status', 200

      it 'renders new' do
        action.call
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT update' do
    let(:action) { proc { put(:update, params: params) } }
    let(:event) { create(:edm_event) }

    context 'with valid params' do
      let(:params) do
        {
          uuid: event.uuid,
          edm_event: {
            skos_prefLabel: 'New label'
          }
        }
      end

      it_behaves_like 'Forbidden for guest user'
      it_behaves_like 'Forbidden for events user'

      context 'when user is an admin' do
        let(:current_user) { create(:user, role: :admin) }
        let(:redirect_location) { controller.events_path }

        it 'updates event with params' do
          action.call
          expect(event.reload.skos_prefLabel).to eq(params[:edm_event][:skos_prefLabel])
        end

        it_behaves_like 'HTTP response status', 302
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          uuid: event.uuid,
          edm_event: {
            skos_prefLabel: ''
          }
        }
      end

      it_behaves_like 'Forbidden for guest user'
      it_behaves_like 'Forbidden for events user'

      context 'when user is an admin' do
        let(:current_user) { create(:user, role: :admin) }

        it 'does not update event' do
          expect { action.call }.not_to change { event.reload.skos_prefLabel }
        end

        it_behaves_like 'HTTP response status', 400

        it 'renders new' do
          action.call
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET delete' do
    let(:action) { proc { get(:delete, params: { uuid: event.uuid }) } }
    let(:event) { create(:edm_event) }

    it_behaves_like 'Forbidden for guest user'
    it_behaves_like 'Forbidden for events user'

    context 'when user is an admin' do
      let(:current_user) { create(:user, role: :admin) }

      context 'when event has no contributions' do
        it 'assigns requested event to @event' do
          action.call
          expect(assigns(:event)).to eq(event)
        end

        it_behaves_like 'HTTP response status', 200
      end

      context 'when event has contributions' do
        before do
          create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, edm_wasPresentAt: event)))
        end

        it_behaves_like 'HTTP response status', 400
      end
    end
  end

  describe 'DELETE destroy' do
    let(:action) { proc { delete(:destroy, params: { uuid: event.uuid }) } }
    let(:event) { create(:edm_event) }

    it_behaves_like 'Forbidden for guest user'
    it_behaves_like 'Forbidden for events user'

    context 'when user is an admin' do
      let(:current_user) { create(:user, role: :admin) }
      let(:redirect_location) { controller.events_path }

      context 'when event has no contributions' do
        it 'destroys event' do
          action.call
          expect { EDM::Event.find(event.id) }.to raise_exception(Mongoid::Errors::DocumentNotFound)
        end

        it_behaves_like 'HTTP response status', 302
      end

      context 'when event has contributions' do
        before do
          create(:contribution, ore_aggregation: build(:ore_aggregation, edm_aggregatedCHO: build(:edm_provided_cho, edm_wasPresentAt: event)))
        end

        it 'does not destroy event' do
          action.call
          expect { EDM::Event.find(event.id) }.not_to raise_exception
        end

        it_behaves_like 'HTTP response status', 302
      end
    end
  end
end
