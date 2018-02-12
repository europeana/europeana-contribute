# frozen_string_literal: true

RSpec.shared_examples '404 Not Found' do
  it 'should respond with status 404' do
    subject.call
    expect(response.status).to eq(404)
  end
end

RSpec.shared_examples '303 See Other' do
  it 'should respond with status 303' do
    subject.call
    expect(response.status).to eq(303)
  end

  it 'redirects to other location' do
    subject.call
    expect(response).to redirect_to(location)
  end
end
