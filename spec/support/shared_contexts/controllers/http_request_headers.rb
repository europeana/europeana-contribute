# frozen_string_literal: true

RSpec.shared_context 'HTTP Accept request header' do
  before do
    request.headers.merge!('Accept': content_type)
  end
end
