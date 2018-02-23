# frozen_string_literal: true

RSpec.describe OAIController do
  RSpec.shared_examples 'an OAI-PMH XML response' do
    it 'renders OAI-PMH XML' do
      get :index, params: params
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/xml')
    end
  end

  describe 'GET index' do
    context 'with no stored stories' do
      it 'responds with 404' do
        get :index
        expect(response.status).to eq(404)
      end
    end

    context 'with at least one published story' do
      let(:xml) { Nokogiri::XML.parse(response.body).remove_namespaces! }

      before(:each) do
        create(:story, :published)
      end

      context 'without verb' do
        let(:params) { {} }
        it_behaves_like 'an OAI-PMH XML response'
      end

      context 'with verb=GetRecord' do
        let(:params) { { verb: 'GetRecord' } }

        it 'observes identifier'
        it 'observes metadataPrefix'
      end

      context 'with verb=Identify' do
        let(:params) { { verb: 'Identify' } }

        it_behaves_like 'an OAI-PMH XML response'

        it 'identifies the repository name' do
          get :index, params: params
          expect(xml.css('OAI-PMH Identify repositoryName').text).to eq('Europeana Stories')
        end

        it 'identifies the earliest Story datestamp' do
          get :index, params: params
          expect(xml.css('OAI-PMH Identify earliestDatestamp').text).to eq(Story.first.created_at.strftime('%FT%TZ'))
        end

        it 'identifies the repository identifier' do
          get :index, params: params
          expect(xml.css('OAI-PMH Identify oai-identifier repositoryIdentifier').text).to eq('europeana:stories')
        end

        it "identifies the repository's deleted record support" do
          get :index, params: params
          expect(xml.css('OAI-PMH Identify deletedRecord').text).to eq('persistent')
        end
      end

      context 'with verb=ListIdentifiers' do
        let(:params) { { verb: 'GetRecord' } }

        it 'observes from'
        it 'observes metadataPrefix'
        it 'observes resumptionToken'
        it 'observes set'
        it 'observes until'
      end

      context 'with verb=ListMetadataFormats' do
        let(:params) { { verb: 'ListMetadataFormats' } }
        it_behaves_like 'an OAI-PMH XML response'

        it 'includes EDM metadata format' do
          get :index, params: params

          expect(response.body.scan(/<metadataFormat>/).count).to eq(1)
          expect(response.body).to include('<metadataPrefix>oai_edm</metadataPrefix>')
          expect(response.body).to include('<schema>http://www.europeana.eu/schemas/edm/EDM.xsd</schema>')
        end
      end

      context 'with verb=ListRecords' do
        let(:params) { { verb: 'ListRecords' } }

        it 'observes from'
        it 'observes metadataPrefix'
        it 'observes resumptionToken'
        it 'observes set'
        it 'observes until'
      end

      context 'with verb=ListSets' do
        let(:params) { { verb: 'ListSets' } }
        it_behaves_like 'an OAI-PMH XML response'

        it 'lists sets from edm:provider values' do
          edm_providers = ['Provider 1', 'Provider 2', 'Provider 3']
          edm_providers.each do |provider|
            create(:story, :published, ore_aggregation: build(:ore_aggregation, :published, edm_provider: provider))
          end

          get :index, params: params

          stored_providers = ORE::Aggregation.distinct(:edm_provider)

          expect(response.body.scan(/<set>/).count).to eq(stored_providers.length)
          stored_providers.each do |provider|
            expect(response.body).to include("<setName>#{provider}</setName>")
            expect(response.body).to match(%{<setSpec>(.*?):#{provider}</setSpec>})
          end
        end
      end
    end
  end
end
