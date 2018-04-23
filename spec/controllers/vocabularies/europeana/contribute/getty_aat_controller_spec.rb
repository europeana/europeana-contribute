# frozen_string_literal: true

RSpec.describe Vocabularies::Europeana::Contribute::GettyAATController do
  describe '.data' do
    it 'is an Array of Getty AAT vocabulary terms' do
      expect(subject.data).to be_a(Array)
      expect(subject.data).to(be_all { |d| d.is_a?(Hash) && d.key?('text') && d.key?('value') })
    end
  end

  describe 'GET index' do
    it 'returns matches from .data' do
      get :index, params: { q: 'ra' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      results = JSON.parse(response.body)
      expect(results).to be_a(Array)
      expect(results).to(be_all { |d| d.is_a?(Hash) && d.key?('text') && d.key?('value') })
      expect(results).to(be_all { |d| d['text'].downcase.start_with?('ra') })
    end
  end

  describe 'GET show' do
    it 'dereferences URI from .data' do
      get :show, params: { uri: 'http://vocab.getty.edu/aat/300387763' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      results = JSON.parse(response.body)
      expect(results).to be_a(Hash)
      expect(results['text']).to eq('Radio program')
    end
  end
end
