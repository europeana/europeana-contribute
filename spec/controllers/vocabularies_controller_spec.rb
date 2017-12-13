# frozen_string_literal: true

RSpec.describe VocabulariesController do
  # No routes to VocabulariesController, so use an anonymous RSpec controller
  controller(VocabulariesController) do
    vocabulary_index url: 'http://api.example.com/search',
                     params: { rows: 5 },
                     query: 'text',
                     results: 'matches',
                     text: 'label',
                     value: 'uri'
  end

  let(:index_options) { subject.class.index_options }
  let(:index_params) { { q: 'fish' } }

  describe 'GET #index' do
    before do
      stub_request(:get, %r{\A#{index_options[:url]}}).to_return(
        body: '{"matches":[{"label":"Result 1","uri":"http://data.example.com/term1"},{"label":"Result 2","uri":"http://data.example.com/term2"}]}',
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'queries the vocabulary API' do
      get :index, params: index_params
      expect(a_request(:get, index_options[:url]).
        with(query: hash_including({ text: 'fish' }))).to have_been_made
    end

    it 'extracts text and values from the response' do
      get :index, params: index_params
      expected = [
        { 'text' => 'Result 1', 'value' => 'http://data.example.com/term1' },
        { 'text' => 'Result 2', 'value' => 'http://data.example.com/term2' }
      ]
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end
end
