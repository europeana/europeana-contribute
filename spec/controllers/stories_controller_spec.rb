# frozen_string_literal: true

RSpec.describe StoriesController do
  describe '#index' do
    context 'when user is authorised' do
      before do
        allow(subject).to receive(:current_user) { create(:user, role: :admin) }
      end

      it 'responds with status code 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'assigns stories to @stories' do
        3.times { create(:ore_aggregation) }
        get :index
        expect(assigns(:stories)).to be_a(Enumerable)
        expect(assigns(:stories).size).to eq(3)
        expect(assigns(:stories).all? { |story| story.is_a?(ORE::Aggregation) }).to be true
      end

      it 'assigns events to @events' do
        5.times { create(:edm_event) }
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
end
