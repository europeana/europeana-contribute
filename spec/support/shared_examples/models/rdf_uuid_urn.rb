# frozen_string_literal: true

RSpec.shared_examples 'RDF UUID URN' do
  describe '#rdf_uri' do
    it { is_expected.to respond_to(:rdf_uri) }
    it { is_expected.to respond_to(:uuid) }

    it 'uses UUID to construct URN' do
      expect(subject.rdf_uri).to eq("urn:uuid:#{subject.uuid}")
    end
  end
end
