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

      it_behaves_like 'HTTP 200 status'
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

      it_behaves_like 'HTTP 200 status'
    end
  end

  describe 'POST create' do
  
  end

  describe 'GET edit' do
  
  end

  describe 'PUT update' do
  
  end

  describe 'GET delete' do
  
  end

  describe 'DELETE destroy' do
    
  end
end
