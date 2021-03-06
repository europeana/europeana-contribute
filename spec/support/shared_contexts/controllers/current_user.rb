# frozen_string_literal: true

RSpec.shared_context 'Controller current_user' do
  let(:current_user) { nil }
  before do
    allow(controller).to receive(:current_user) { current_user }
  end
end
